#!/usr/bin/env ruby

HELP = <<HELP
HELP

USAGE = <<USAGE
Usage: git compress [tag] [options]
If [tag] is not specified, git-compress will do nothing. The possible
[options] are:
  -h, --help          displays this help
USAGE

COPYRIGHT = <<COPYRIGHT
git-compress Copyright 2015--2016 Frank West
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


def main
  return no_commit_provided_error unless commit
  return no_tag_provided_error unless tag
  original_commit = initial_commit

  parsed_commits = parse_commits_by_tag

  reset_to_commit

  parsed_commits.each do |parent|
    `git cherry-pick #{parent[:sha]}`
    parent[:children].each do |child|
      `git cherry-pick --no-commit #{child[:sha]}`
      `git commit --amend --no-edit`
    end
  end

rescue
  puts "Reset by running git reset --hard #{original_commit}"
end

def commit
  @commit ||= ARGV[0]
end

def tag
  @tag ||= ARGV[1]
end

def reset_to_commit
  `git reset --hard #{commit}`
end

def commits
  `git log #{commit}.. --oneline --reverse`.split("\n").map do |commit|
    sha, message = commit.match(/(.*?)\s(.*)/).captures
    { sha: sha, message: message.strip, children: [] }
  end
end

def parse_commits_by_tag
  parent = nil
  commits.each_with_object([]) do |commit, result|
    if commit[:message] == tag
      unless parent
        puts "Error: Compressed commit cannot be a WIP itself"
        exit
      end
      parent[:children] << commit
    else
      parent = commit
      result << commit
    end
  end
end

def initial_commit
  @initial_commit ||= `git rev-parse HEAD`
end

def no_commit_provided_error
  puts "Error: You must provide a commit sha or name when calling git compress"
end

def no_tag_provided_error
  puts "Error: You must provide a tag when calling git compress"
end

main
