source 'https://rubygems.org'

gem 'rake'
gem "cocoapods", "1.8.0"
gem "motion-cocoapods", "1.10.0"

# gem 'motion-firebase', path: '../motion-firebase'
gem 'motion-firebase', git: 'git@github.com:ljorgens/motion-firebase.git'


#POTENTIAL SOLUTIONS I HAVE TRIED
# In Pod File I added:
# pod 'FirebaseUI/Phone', "~> 8.0"
# pod 'FirebaseUI/OAuth', "~> 8.0"
# I tried a bunch of different versions but these should be the minimum pods to make it work and am still running into an issue
# Even if i could get this to work its not the ideal solution because I dont think we could put it in the motion firebase gem and there fore harder to share with the community

# Better solution (I think)
# https://firebase.google.com/docs/auth/ios/apple
# Create a vendor file with the Objective C code at the above link and inject it into FIRAuth and interact with the
# apple login that way.  I ran into issues with this too... wasnt sure how to trigger the apple login flow successfully



