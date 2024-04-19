# platform :ios, '9.0'

target 'Exercises' do
 
  use_frameworks!

  # Pods for Exercises 
  # pod 'Firebase/Analytics'
  # pod 'Firebase/Firestore'
  pod 'FirebaseCore'
pod 'GoogleSignIn'
  pod 'FirebaseAuth'
end

post_install do |installer|
    installer.generated_projects.each do |project|
          project.targets.each do |target|
              target.build_configurations.each do |config|
                  config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '17.4'
               end
          end
   end
end
