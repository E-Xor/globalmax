# Install and run

* Install rvm and ruby
```
gem install bundler -v "2.3.23"
bundle install

jekyll serve
```

Open in browser http://127.0.0.1:4000/

# Release

## Manual

* `jekyll build` Without that variables will have development values
* Upload _site to S3 Bucket
* Don't click Upload, click Next, then Manage public permissions -> Grant public read access
* Or if already uploaded and webstite returns 403, select all files and folders in a bucket -> Action -> Make public

## deploy.rb

* Put credentials in aws.yml
* Run `./deploy.rb`
