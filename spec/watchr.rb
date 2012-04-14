# Run me with:
#   $ watchr spec/watchr.rb

# --------------------------------------------------
# Rules
# --------------------------------------------------
watch( '^spec/(.*)/(.*)_spec\.rb' ) { |m| rspec m[0] }
watch( '^spec/(.*)_spec\.rb' ) { |m| rspec m[0] }
watch( '^lib/(.*)\.rb' ) { |m| rspec "spec/unit/#{m[1]}_spec.rb" }
watch( '^lib/(.*)/(.*)\.rb' ) { |m| rspec "spec/unit/#{m[2]}_spec.rb" }

# --------------------------------------------------
# Signal Handling
# --------------------------------------------------
Signal.trap('INT' ) { abort("\n") } # Ctrl-C

# --------------------------------------------------
# Helpers
# --------------------------------------------------

def rspec(path)
  run "clear"
  if not File.exists?(path)
    puts "File #{path} does not exist!"
  elsif File.read(path).include?(":focus => true")
    run_rspec "-t @focus #{path}"
  else
    run_rspec path
  end
end

def run_rspec(cmd)
  run "bundle exec rspec -c -b #{cmd}"
end

def run(cmd)
  puts   cmd
  system cmd
end


