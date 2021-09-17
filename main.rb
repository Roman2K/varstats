require 'utils'
require 'sequel'
require 'sequel/extensions/migration'

class Cmds
  def initialize
    @log = Utils::Log.new level: (ENV["DEBUG"] == "1" ? :debug : :info)
    @conf = Utils::Conf.new "config.yml"

    @db = Sequel.connect @conf[:db][:url]
    @db.logger = @log if @log.level == :debug
    @log.info "running migrations" do
      Sequel::Migrator.run @db, __dir__ + '/db', use_transactions: true
    end
  end

  def cmd_save
    http = Utils::SimpleHTTP.new @conf[:bazarr][:url], json: true
    http.req_filters << -> req {
      req['x-api-key'] = @conf[:bazarr][:api_key]
    }
    data = http.get "/api/badges"
    rec = {time: Time.now}
    %i[episodes movies providers].each do |attr|
      rec[attr] = data.fetch attr.to_s
    end
    id = @db[:bazarr_stats].insert rec
    pp id => rec
  end
end

if $0 == __FILE__
  require 'metacli'
  MetaCLI.new(ARGV).run Cmds.new
end
