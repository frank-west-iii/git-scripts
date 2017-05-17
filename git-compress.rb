#!/usr/bin/env ruby

HELP = <<HELP
HELP

USAGE = <<USAGE
Usage: git compress [branch] [message] [options]
If [branch] or [message] is not specified, git-compress will do nothing. The possible
[options] are:
  -h, --help          displays this help
USAGE

COPYRIGHT = <<COPYRIGHT
git-compress Copyright 2015--2017 Frank West
<frank dot west dot iii at gmail dot com>.
This is free and unencumbered software released into the public domain.
Anyone is free to copy, modify, publish, use, compile, sell, or distribute this
software, either in source code form or as a compiled binary, for any purpose,
commercial or non-commercial, and by any means.
In jurisdictions that recognize copyright laws, the author or authors of this
software dedicate any and all copyright interest in the software to the public
domain. We make this dedication for the benefit of the public at large and to
the detriment of our heirs and successors. We intend this dedication to be an
overt act of relinquishment in perpetuity of all present and future rights to
this software under copyright law.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF
CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
For more information, please refer to http://unlicense.org
COPYRIGHT

if ARGV.delete("--help") || ARGV.delete("-h")
  puts USAGE
  exit
end

Commit = Struct.new(:sha, :message)

class Compress
  def initialize(commit, message)
    @commit = commit
    @message = message
    @errors = []
    @original_commit = `git rev-parse HEAD`.chomp
  end

  def call
    return display_errors unless valid?
    reset_to_commit
    compress
  ensure
    puts "Reset by running git reset --hard #{original_commit}"
  end

  protected

  attr_reader :commit, :errors, :message, :original_commit

  def valid?
    unless commit
      self.errors << "You must provide a commit sha or name when calling git compress"
    end

    unless message
      self.errors << "You must provide a message when calling git compress"
    end

    unless clean_status
      self.errors << "You have changes in your repo. Please commit or stash before proceeding."
    end

    errors.count == 0
  end

  def clean_status
    !!(`git status` =~ /nothing to commit, working directory clean/)
  end

  def display_errors
    puts "Error:\n#{errors.join("\n")}\ne.g. git compress master WIP"
  end

  def reset_to_commit
    `git reset --hard #{commit}`
  end

  def compress
    compressables = []
    commits.each do |commit|
      if commit.message == message
        compressables << commit
      else
        compressables.each do |compressable|
          `git cherry-pick -n #{compressable.sha}`
        end
        message = `git show -s --format=%B #{commit.sha}`
        `git cherry-pick -n #{commit.sha}`
        `git commit -m "#{message}"`
        compressables = []
      end
    end
    compressables.each do |compressable|
      `git cherry-pick #{compressable.sha}`
    end
  end

  def commits
    return @_commits if defined?(@_commits)
    raw = `git log #{commit}..#{original_commit} --oneline --reverse`
    @_commits = raw.split("\n").map do |commit|
      Commit.new(*commit.match(/(.*?)\s(.*)/).captures)
    end
  end
end

Compress.new(ARGV[0], ARGV[1]).call
