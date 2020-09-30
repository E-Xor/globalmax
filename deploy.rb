#!/usr/bin/env ruby

require 'yaml'

AWS_KEYS = YAML::load(File.open("aws.yml")).transform_keys(&:to_sym)

BUCKET = 'globalmaxnet'
# BUCKET = 'globalmaxnettest'

# require 'aws-sdk-s3'

# puts 'AWS SDK S3 List'

# s3 = Aws::S3::Resource.new({
#   region: 'us-east-1',
#   access_key_id: AWS_KEYS[:key],
#   secret_access_key: AWS_KEYS[:secret]
# })

# puts s3.bucket(BUCKET).objects(prefix:'', delimiter: '').collect(&:key)
# puts

require 'fog-aws'

puts 'List'

connection = Fog::Storage.new({
  provider:             'AWS',
  aws_access_key_id:     AWS_KEYS[:key],
  aws_secret_access_key: AWS_KEYS[:secret]
})

directory = connection.directories.get(BUCKET)
# puts directory.files.map(&:key)
directory.files.each do |f|
  puts "Removing #{f.key}"
  f.destroy
end

puts
puts 'Uploading'

files       = Dir.glob(File.join('_site/**/*')).select { |f| !File.directory?(f) }
total_files = files.size
file_number = 0
total_size  = 0
@mutex      = Mutex.new
threads     = []

3.times do |i|
  threads[i] = Thread.new do
    until files.empty?
      @mutex.synchronize do
        file_number += 1
        Thread.current[:file_number] = file_number
      end

      file = files.pop rescue nil
      if file
        puts "[ #{Thread.current[:file_number]} / #{total_files} ] #{file}"
        total_size += File.size(file)

        directory.files.create(
          :key    => file[6..-1], # removes _site/ in the front
          :body   => File.open(file),
          :public => true
        )
      end
    end
  end
end

start = Time.now

threads.each { |t| t.join }

# No threads

# Dir.glob(File.join('_site/**/*')).select { |f| !File.directory?(f) }.each do |f|
#   puts f

#   directory.files.create(
#     :key    => f,
#     :body   => File.open(f),
#     :public => true
#   )
# end

finish  = Time.now
elapsed = finish.to_f - start.to_f
mins, secs = elapsed.divmod 60.0
puts("Uploaded %d files (%.#{0}f KB) in %d min %d sec" % [total_files, total_size / 1024.0, mins, secs])

puts "Now go and invalidate the CloudFront distribution to propagate the update."

