# DryCare Play release checklist

Draft listing title: DryCare: Dry Skin Routine

Short description: Track your skincare routine and explore general dry skin care tips.

Full description: DryCare helps you build a consistent facial skincare routine. Answer ten questions about your skin and habits to see a general, self-reported guide. Check off morning and night skincare steps, record glasses of water, and read six built-in articles. Progress and preferences are stored on your device. DryCare provides general skincare and wellness information. Its questionnaire does not diagnose a condition or replace professional medical advice. Seek qualified advice for persistent or concerning symptoms.

## Manual Play Console work

- Confirm ownership and availability of application ID `com.drycare.drycare`.
- Decide target audience and minimum age; align the in-app age validation before submission.
- Publish `PRIVACY_POLICY.md` on a public, non-geofenced website after filling in developer identity, contact, and verified network behavior. Enter its URL in Play Console.
- Complete Health apps declaration for the final skincare functionality. Describe the questionnaire as nonclinical.
- Complete Data safety after checking the final AAB and network traffic. Local Hive storage alone does not count as off-device collection under Google's definition. Confirm font and other SDK behavior before selecting “no data collected.”

## Draft Data safety answers (verify against the final signed release)

- The app stores name, age, skincare questionnaire answers and score, water and routine tracking, streak, and theme preference on device.
- No account, ads, analytics, app backend, or intentional off-device transfer of these entries is present in application code.
- If final release inspection confirms that no SDK transmits user data, select **no data collected** and **no data shared** under Google's off-device Data safety definitions. Do not submit these answers until font loading and merged permissions have been checked.
- Users can delete local entries through Settings > Reset All Data. Android backup is disabled in the app manifest. The Hive database is not separately encrypted.
- A public privacy policy is still required and must describe local processing even if the Data safety form says no off-device collection.
- Complete content rating, target audience, ads (“No ads” if unchanged), app access, and all other App content questionnaires.
- Supply a 512×512 listing icon, 1024×500 feature graphic, and actual phone screenshots: dashboard, questionnaire, result, routines, water tracker, and articles. Avoid clinical claims in artwork.
- Create an upload keystore outside the repository. Keep passwords in `android/key.properties` (ignored by Git), using `storeFile`, `storePassword`, `keyAlias`, and `keyPassword`. Back up the keystore and credentials securely. Enable Play App Signing.
- Build with `flutter build appbundle --release`, then verify package ID, version, target SDK, merged permissions, and upload-key signature before uploading. Increment the version code for every later upload.
- Test on physical Android devices, including Android 13 and 16, small screens, large text, TalkBack, dark/light modes, offline launch, day rollover, retake, and erase.
- Upload first to internal testing. If the account is a personal developer account created after 13 November 2023, complete the required closed test with 12 continuously opted-in testers for 14 days and apply for production access.
