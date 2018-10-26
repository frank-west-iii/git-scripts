#!/usr/bin/env ruby

HELP = <<HELP
git-guess allows you to provide a partial branch name for checking out a branch.
If only one name matches what you provide it will perform a checkout on that
branch. If multiple branches are found it will allow you to select by number in
order to checkout the correct branch. Otherwise it will do nothing.
HELP

USAGE = <<USAGE
Usage: git guess [branch] [options]
If [branch] is not specified, git-guess will do nothing. The possible
[options] are:
  -h, --help          displays this help
USAGE

COPYRIGHT = <<COPYRIGHT
git-guess Copyright 2015--2016 Frank West
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

if ARGV.delete('--help') || ARGV.delete('-h')
  puts USAGE
  exit
end

def main
  case branches.count
  when 0
    puts "No branches found containing the text #{guess}"
  when 1
    `git checkout #{branches.first}`
  else
    multiple_branches_found
  end
end

def get_selection
  puts 'Select a branch:'
  branches.each_with_index do |branch, index|
    puts "[#{index + 1}] - #{branch}"
  end
  puts '[q] - Quit'
  selection = STDIN.gets.chomp
  exit if selection == 'q'

  selection.to_i
end

def branches
  return @branches if defined?(@branches)
  all_branches = `git branch -a`.split("\n").map { |branch| branch.split.last.gsub(/^.*origin\//, '') }
  @branches = all_branches.uniq.select do |branch|
    Regexp.new(/#{guess}/) =~ branch
  end
end

def guess
  @guess ||= ARGV.first
end

def multiple_branches_found
  selection = get_selection
  if allowed_selections.include?(selection)
    `git checkout #{branches[selection - 1]}`
  else
    puts 'Not a valid selection. Please try again'
    multiple_branches_found
  end
end

def allowed_selections
  @allowed_selections ||= (1..branches.count)
end

main
