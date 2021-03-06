require 'proxy/log_buffer/decorator'
require 'proxy/log_buffer/buffer'

module Proxy::LogBuffer
  class Decorator
    def initialize(logger, buffer = Proxy::LogBuffer::Buffer.instance)
      @logger = logger
      @buffer = buffer
    end

    def add(severity, message = nil, progname = nil, backtrace = nil, a_module = 'core', &block)
      severity ||= UNKNOWN
      progname ||= @logger.progname
      if message.nil?
        if block_given?
          message = yield
        else
          message = progname
          progname = @logger.progname
        end
      end
      # add to the logger first
      @logger.add(severity, message, progname)
      @logger.add(::Logger::Severity::DEBUG, backtrace) if backtrace
      # add add to the buffer
      if severity >= @logger.level
        # we accept backtrace, exception and simple string
        backtrace = backtrace.is_a?(Exception) ? backtrace.backtrace : backtrace
        backtrace = backtrace.respond_to?(:join) ? backtrace.join("\n") : backtrace
        rec = Proxy::LogBuffer::LogRecord.new(nil, severity, message, backtrace)
        @buffer.push(rec)
      end
    end

    def debug(msg_or_progname, exception_or_backtrace = nil, &block)
      add(::Logger::Severity::DEBUG, nil, msg_or_progname, exception_or_backtrace, caller, &block)
    end

    def info(msg_or_progname, exception_or_backtrace = nil, &block)
      add(::Logger::Severity::INFO, nil, msg_or_progname, exception_or_backtrace, caller, &block)
    end
    alias_method :write, :info

    def warn(msg_or_progname, exception_or_backtrace = nil, &block)
      add(::Logger::Severity::WARN, nil, msg_or_progname, exception_or_backtrace, caller, &block)
    end
    alias_method :warning, :warn

    def error(msg_or_progname, exception_or_backtrace = nil, &block)
      add(::Logger::Severity::ERROR, nil, msg_or_progname, exception_or_backtrace, caller, &block)
    end

    def fatal(msg_or_progname, exception_or_backtrace = nil, &block)
      add(::Logger::Severity::FATAL, nil, msg_or_progname, exception_or_backtrace, caller, &block)
    end

    def method_missing(symbol, *args);
      @logger.send(symbol, *args)
    end
  end
end
