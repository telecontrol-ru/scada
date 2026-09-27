#!/usr/bin/env ruby
# frozen_string_literal: true

# Checks every internal link and image in a BUILT site: the target page must
# exist, and a `#fragment` must name an element id on that page.
#
#   ruby scripts/check_site_links.rb <site-dir> [--baseurl /scada]
#
# This is the check the two source validators cannot be. Both of the defects
# it was written for looked correct in the Markdown and were visible only in
# the output (found 2026-09-27, every internal link on the Russian
# architecture page returned 404):
#
# - A bare relative link such as `[Сервер](server)` on a page whose permalink
#   ends in `/` resolves against that directory, to `/architecture/server`.
#   jekyll-relative-links does not rescue it: it rewrites links to `.md` files
#   only (https://github.com/benbalter/jekyll-relative-links#readme).
# - A heading written `## [](#data-items)Title` renders an empty link and an
#   id derived from the title, so `#data-items` names nothing. An explicit id
#   is `## Title {#data-items}`.
#
# Stdlib only, and Ruby 2.6-compatible, like the other scripts here: the
# generated HTML is regular enough that attributes are read with a regex.

require "cgi"
require "set"
require "uri"

site_dir = ARGV[0]
baseurl = ""
if (i = ARGV.index("--baseurl"))
  baseurl = ARGV[i + 1].to_s.chomp("/")
end
abort("usage: check_site_links.rb <site-dir> [--baseurl /prefix]") unless site_dir && File.directory?(site_dir)
site_dir = File.expand_path(site_dir)

# Site-relative URL path of a generated file, e.g. "/architecture/".
def url_path_for(file, site_dir)
  rel = file.delete_prefix(site_dir)
  rel.end_with?("/index.html") ? rel.delete_suffix("index.html") : rel
end

# The generated file a site-relative path names, or nil.
def file_for(path, site_dir)
  path = CGI.unescape(path)
  candidates = if path.end_with?("/")
                 [path + "index.html"]
               else
                 [path, path + ".html", path + "/index.html"]
               end
  candidates.map { |c| File.join(site_dir, c) }.find { |f| File.file?(f) }
end

ids_cache = {}
ids_for = lambda do |file|
  ids_cache[file] ||= File.read(file, encoding: "UTF-8")
                          .scan(/\s(?:id|name)="([^"]*)"/).flatten.map { |s| CGI.unescapeHTML(s) }.to_set
end

failures = []
html_files = Dir.glob(File.join(site_dir, "**", "*.html")).sort
html_files.each do |file|
  html = File.read(file, encoding: "UTF-8")
  # Only the page body: the theme's own chrome (nav, search, footer) is not
  # ours to fix and is identical on every page.
  main = html[%r{<main\b.*?</main>}m] or next
  page_url = URI("https://site.invalid#{baseurl}#{url_path_for(file, site_dir)}")

  main.scan(/\s(?:href|src)="([^"]*)"/).flatten.uniq.each do |raw|
    ref = CGI.unescapeHTML(raw)
    next if ref.empty? || ref.match?(/\A(?:[a-z][a-z0-9+.-]*:|\/\/)/i)

    begin
      # Kramdown ids are Cyrillic on the Russian pages, and URI accepts
      # ASCII only.
      target = page_url + ref.gsub(/[^\x00-\x7F]/) { |c| CGI.escape(c) }
    rescue URI::Error
      failures << [file, ref, "unparseable"]
      next
    end
    path = target.path
    unless baseurl.empty? || path == baseurl || path.start_with?("#{baseurl}/")
      failures << [file, ref, "outside #{baseurl}"]
      next
    end
    path = path.delete_prefix(baseurl)
    path = "/" if path.empty?

    target_file = file_for(path, site_dir)
    unless target_file
      failures << [file, ref, "no page #{path}"]
      next
    end
    fragment = target.fragment
    next if fragment.nil? || fragment.empty?

    id = CGI.unescape(fragment)
    failures << [file, ref, "no ##{id} on #{path}"] unless ids_for.call(target_file).include?(id)
  end
end

if failures.empty?
  puts "OK: internal links resolve in #{html_files.size} pages"
  exit 0
end

failures.each do |file, ref, why|
  puts "#{file.delete_prefix(site_dir + '/')}: #{ref} -> #{why}"
end
puts "#{failures.size} broken internal link(s)"
exit 1
