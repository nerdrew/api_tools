if defined?(Rails) && Rails.env.development?
  require 'rake/hooks'

  after :"db:schema:dump" do
    old_schema = File.open(Rails.root.join 'db', 'schema.rb') {|f| f.read }
    File.open(Rails.root.join('db', 'schema.rb'), 'w') do |f|
      old_schema.each_line do |line|
        f.write line.gsub(/(\S) +/, '\1 ')
      end
    end
  end
end
