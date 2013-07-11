require 'date'
require 'pathname'

module Twig
  class Repo
    class InvalidRepoError < RuntimeError; end

    def initialize(path)
      @path = Pathname.new(path)
      raise InvalidRepoError unless valid?
    end

    def commits(options = {})
      args = []
      args << '--all' if options[:all]
      args << "--since=#{options[:since].to_i}" if options[:since]
      @commits ||= {}
      @commits[options] ||= parse_log(log(*args))
    end

    def name
      @path.basename.to_s
    end

  private

    # Check to see if this is a valid repo:
    #
    #   - the repo path should exist
    #   - the path should point to the top level of the repo
    #   - the check should work for both bare and non-bare repos
    #
    def valid?
      # Of the various options to `git rev-parse`, `--show-prefix` gives us the
      # simplest way to fulfil these conditions.
      prefix = git('rev-parse', '--show-prefix').chomp
      $?.success? && prefix == ''
    rescue Errno::ENOENT
      false
    end

    def git(command, *args)
      Dir.chdir @path do
        # send both stderr and stdout to stdout
        IO.popen(['git', command, *args, err: [:child, :out]]) do |io|
          io.read
        end
      end
    end

    def log(*args)
      git 'log', '--numstat', '--format=raw', *args
    end

    def parse_log(string)
      [].tap do |commits|
        tokens = string.scan %r{
          ^commit\s+([a-f0-9]{40})$ |                  # digest
          ^author\s+(.+)\s+<.+>\s\d+\s[+-]\d{4}$ |     # author (name)
          ^committer\s+.+\s+<.+>\s(\d+)\s[+-]\d{4}$ |  # committer (date)
          ^[ ]{4}(.+?)$ |                              # subject + message
          ^(\d+)\t(\d+)\t.+$                           # num stats (per file)
        }x

        while token = tokens.shift
          commit  = token[0]
          author  = tokens.shift[1]
          date    = Time.at(tokens.shift[2].to_i).to_date
          subject = tokens.shift[3]
          tokens.shift while tokens.first && tokens.first[3] # commit message body, drop

          stat = Hash.new(0)
          while tokens.first && tokens.first[4] && token = tokens.shift
            stat[:additions] += token[4].to_i
            stat[:deletions] += token[5].to_i
          end

          commits << Commit.new(repo:    self,
                                commit:  commit,
                                subject: subject,
                                author:  author,
                                date:    date,
                                stat:    stat)
        end
      end
    end
  end
end
