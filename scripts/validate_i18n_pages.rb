#!/usr/bin/env ruby
# frozen_string_literal: true

require "pathname"
require "set"
require "yaml"

SITE_ROOT = Pathname.new(__dir__).join("..").expand_path
MAP_PATH = SITE_ROOT.join("_data", "i18n_pages.yml")

def normalized_permalink(path)
  value = path.to_s.strip
  return "/" if value == "/"

  value = "/#{value}" unless value.start_with?("/")
  value.end_with?("/") ? value : "#{value}/"
end

def markdown_files
  Dir.glob(SITE_ROOT.join("**", "*.md")).sort
end

def inferred_permalink(relative_path)
  path = relative_path.sub(/\.md\z/, "")
  path = path.sub(%r{(^|/)index\z}, "")
  normalized_permalink(path.empty? ? "/" : path)
end

def extract_front_matter(file_path)
  lines = File.readlines(file_path, chomp: true)
  return nil unless lines.first == "---"

  closing_index = lines[1..].index("---")
  return nil unless closing_index

  YAML.safe_load(lines[1..closing_index].join("\n"), permitted_classes: [], aliases: false) || {}
rescue Psych::SyntaxError => e
  abort "YAML front matter parse error in #{file_path}: #{e.message}"
end

def collect_permalinks
  by_permalink = Hash.new { |hash, key| hash[key] = [] }

  markdown_files.each do |file_path|
    front_matter = extract_front_matter(file_path)
    relative_path = Pathname.new(file_path).relative_path_from(SITE_ROOT).to_s

    permalink =
      if front_matter.is_a?(Hash) && front_matter["permalink"]
        normalized_permalink(front_matter["permalink"])
      else
        inferred_permalink(relative_path)
      end

    by_permalink[permalink] << relative_path
  end

  by_permalink
end

def validate_unique_page_permalinks(by_permalink)
  duplicates = by_permalink.select { |_permalink, files| files.size > 1 }
  return if duplicates.empty?

  lines = ["Duplicate page permalinks found:"]
  duplicates.sort.each do |permalink, files|
    lines << "  #{permalink}: #{files.join(', ')}"
  end
  abort lines.join("\n")
end

def load_pair_mappings
  data = YAML.safe_load_file(MAP_PATH, permitted_classes: [], aliases: false)
  abort "#{MAP_PATH} must contain a YAML sequence" unless data.is_a?(Array)

  data
end

def validate_pair_mappings(by_permalink, mappings)
  seen = {}
  errors = []

  mappings.each_with_index do |entry, index|
    unless entry.is_a?(Hash)
      errors << "Entry ##{index + 1} in #{MAP_PATH} is not a mapping"
      next
    end

    %w[ru en].each do |lang|
      if entry[lang].to_s.strip.empty?
        errors << "Entry ##{index + 1} is missing '#{lang}'"
      end
    end

    next unless errors.empty? || errors.last !~ /^Entry ##{index + 1}/

    ru = normalized_permalink(entry["ru"])
    en = normalized_permalink(entry["en"])

    [["ru", ru], ["en", en]].each do |lang, permalink|
      if seen.key?(permalink)
        errors << "Duplicate #{lang} mapping for #{permalink}: entries ##{seen[permalink]} and ##{index + 1}"
      else
        seen[permalink] = index + 1
      end

      unless by_permalink.key?(permalink)
        errors << "Mapped #{lang} permalink does not exist as a page: #{permalink}"
      end
    end
  end

  abort errors.join("\n") unless errors.empty?
end

permalinks = collect_permalinks
validate_unique_page_permalinks(permalinks)
validate_pair_mappings(permalinks, load_pair_mappings)

puts "Validated #{permalinks.size} page permalinks and #{YAML.safe_load_file(MAP_PATH).size} i18n mappings."
