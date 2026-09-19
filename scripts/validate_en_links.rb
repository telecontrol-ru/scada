#!/usr/bin/env ruby
# frozen_string_literal: true

require "pathname"

SITE_ROOT = Pathname.new(__dir__).join("..").expand_path
EN_ROOT = SITE_ROOT.join("en")

# Any depth of `../`, not just one. The rule matched the literal `../img/`
# until 2026-09-19, and `en/client/workbench.md` carried TWO `../../img/`
# references that slipped past it and reached the published site — from the
# permalink /en/client/workbench/, `../../` resolves to /en/, so both asked
# for /en/img/<name>, which does not exist. One level deeper than the rule
# written for exactly this failure.
FRAGILE_IMAGE_PATTERN = %r{!\[[^\]]*\]\((?:\.\./)+img/}
NON_EN_RELATIVE_URL_PATTERN = /\{\{\s*'\/(?!en\/|img\/)([^']+)'\s*\|\s*relative_url\s*\}\}/
NON_EN_MARKDOWN_LINK_PATTERN = %r{\[[^\]]+\]\((?!https?://)(?!mailto:)(?!#)(?!\{\{\s*'/en/)(?!\{\{\s*'/img/)([^)]+)\)}

def markdown_files
  Dir.glob(EN_ROOT.join("**", "*.md")).sort
end

def relative_path(file_path)
  Pathname.new(file_path).relative_path_from(SITE_ROOT).to_s
end

errors = []

markdown_files.each do |file_path|
  # Explicit UTF-8: the English pages link to Russian-named assets and quote
  # Russian UI labels, so under a locale that leaves the default external
  # encoding US-ASCII the first `line.match?` below raises "invalid byte
  # sequence" rather than reporting anything. Do not rely on the caller's
  # RUBYOPT/LANG for this.
  content = File.read(file_path, encoding: "UTF-8")
  rel_path = relative_path(file_path)

  content.each_line.with_index(1) do |line, line_number|
    if line.match?(FRAGILE_IMAGE_PATTERN)
      errors << "#{rel_path}:#{line_number}: fragile ../img path in English page"
    end

    if (match = line.match(NON_EN_RELATIVE_URL_PATTERN))
      errors << "#{rel_path}:#{line_number}: non-English internal relative_url target '/#{match[1]}'"
    end

    next unless (match = line.match(NON_EN_MARKDOWN_LINK_PATTERN))

    target = match[1]
    next if target.start_with?("http://", "https://", "mailto:", "#")

    errors << "#{rel_path}:#{line_number}: raw markdown link target '#{target}' should use /en/ or relative_url"
  end
end

abort errors.join("\n") unless errors.empty?

puts "Validated #{markdown_files.size} English markdown files for image and internal-link conventions."
