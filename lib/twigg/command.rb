module Twigg
  class Command
    # Subcommands, in the order they should appear in the help output.
    SUBCOMMANDS = %w[help app stats gerrit]

    autoload :Gerrit, 'twigg/command/gerrit'
    autoload :Help,   'twigg/command/help'
    autoload :Stats,  'twigg/command/stats'

    class << self
      def run(subcommand, *args)
        Help.new('usage').die unless SUBCOMMANDS.include?(subcommand)

        if args.include?('-h') || args.include?('--help')
          Help.new(subcommand).die
        end

        debug = true if args.include?('-d') || args.include?('--debug')

        begin
          send(subcommand, *args)
        rescue => e
          raise if debug

          stderr "error: #{e.message}",
            '[run with -d or --debug flag to see full stack trace]'
          exit 1
        end
      end

      def stderr(*msgs)
        STDERR.puts(*msgs)
      end

      def die(msg = nil)
        stderr("error: #{msg}") if msg
        exit 1
      end

    private

      def warn(msg)
        stderr "warning: #{msg}"
      end

      def ignore(args)
        warn "unsupported extra arguments #{args.inspect} ignored" if args.any?
      end

      def app(*args)
        ignore args
        App.run!
      end

      def gerrit(*args)
        Gerrit.new(*args)
      end

      def help(topic = nil, *args)
        ignore args
        Help.new(topic)
      end

      def stats(*args)
        Stats.new(*args)
      end
    end

    extend Forwardable
    def_delegators 'self.class', :die, :stderr

    def initialize(*args)
      @debug   = true if args.delete('-d') || args.delete('--debug')
      @verbose = true if args.delete('-v') || args.delete('--verbose')
      @args    = args
    end

  private

    def strip_heredoc(doc)
      indent = doc.scan(/^[ \t]*(?=\S)/).map(&:size).min || 0
      doc.gsub(/^[ \t]{#{indent}}/, '')
    end
  end
end
