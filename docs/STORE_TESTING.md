# Testing Connect IQ Store Settings Updates

This guide summarizes the workflow discussed in the Garmin developer forum thread about verifying store-managed settings changes before allowing an update to go live. The key idea is to use the Connect IQ Store's staging flow and the review note flag to freeze approval while you test.

## Recommended Workflow

1. **Prepare a New Build**  
   Compile and package the watch face or app locally. Increment the version in `manifest.xml` and regenerate your `.iq` bundle so the store recognizes it as a distinct submission.

2. **Upload as a Pending Update**  
   In the Connect IQ Store developer portal, create a new version of the app and upload the `.iq` package. Fill out the required metadata but keep the listing unchanged for the public until testing is complete.

3. **Set the Review Note to “Do not approve”**  
   In the *Review Notes* field, add a clear instruction such as **“Do not approve – internal settings test only.”** This prevents Garmin’s review team from approving and publishing the build while you evaluate the settings experience.

4. **Install the Pending Version to Test Devices**  
   Use the store’s *Test on Device* or direct download option (available to the app owner and authorized testers) to install the pending version on your watch or simulator. Because the build is staged in the store backend, you can verify the full settings flow exactly as end users will see it, including cloud-synced preferences.

5. **Iterate as Needed**  
   If you discover issues, replace the pending build with a new package and keep the review note flagged as “Do not approve.” Repeat installation from the store until you are satisfied with the behavior.

6. **Greenlight the Release**  
   Once testing is complete, update the review note (e.g., remove the “Do not approve” instruction) and notify the reviewers that the build is ready. The Garmin team can then run their checks and publish the update.

## Why This Matters

Settings that are hosted and delivered through the Connect IQ Store cannot be fully exercised offline because the store manages the configuration UI and synchronization to devices. Staging the build in the store gives you the same environment your users experience, ensuring that:

- New or renamed settings appear correctly in the Connect IQ mobile app and web store.
- Default values, validation, and translations behave as expected.
- Existing installations migrate without data loss.

Using the “Do not approve” note keeps the pending version from being released prematurely while still allowing you to perform end-to-end validation.

## Tips

- Keep a short changelog in the review note so Garmin’s reviewers understand the context once you are ready for approval.
- Coordinate with any beta testers: only accounts added to the tester list will see the pending build in the store.
- After approval, double-check that the review note no longer contains “Do not approve” to avoid confusion on future submissions.
