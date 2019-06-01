require 'we_transfer_client'

commit = ENV.fetch("TRAVIS_COMMIT")[0..6]
jobName = ENV.fetch("TRAVIS_JOB_NUMBER")
buildName = ENV.fetch("TRAVIS_BUILD_NUMBER")
title = ENV.fetch("COMMIT_SUBJECT")
author = ENV.fetch("AUTHOR_NAME")
message = "Job: #{jobName}, Build: #{buildName}\n\n#{title} (#{author})"

client = WeTransfer::Client.new(api_key: ENV.fetch('WT_API_KEY'))
transfer = client.create_transfer_and_upload_files(message: message) do |upload|
  upload.add_file(name: "ApolloTV Build #{buildName} - #{commit}.apk", io: File.open('./build/app/outputs/apk/release/app-release.apk', 'rb'))
end

puts transfer.url
