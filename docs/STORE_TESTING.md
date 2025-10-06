# Staging Garmin Connect IQ Store Releases

Two store features help you verify updates before they reach every user:

| Goal | Feature to use |
| --- | --- |
| Test the production-bound build while preventing Garmin from publishing it | **Review note: “Do not approve”** |
| Run a closed beta that stays hidden from the public catalog | **Version name prefixed with `BETA`** |

Both options require you to upload the `.iq` package to the Connect IQ Store so you can exercise the store-managed settings and distribution pipeline.

## “Do not approve” review note

Choose this path when you expect the submitted build to become the public release after you finish validation.

1. Upload the new version in the developer portal with its normal version name.
2. In the *Review Notes* field, add a clear instruction such as **“Do not approve – internal testing.”**
3. Install the pending build on devices via *Test on Device* or direct download. Iterate by replacing the package as needed; keep the note until you are satisfied.
4. When ready to launch, remove the “Do not approve” text (and optionally message the reviewers) so Garmin can complete approval and publish the same submission.

**Use it when** you want Garmin to release this exact build once you give the green light.

## `BETA` version name

Use the hidden beta channel to share a build only with designated testers.

1. Upload the build and set the *Version Name* to start with `BETA` (for example, `BETA 1.4.0`).
2. Populate the tester list so the right Garmin accounts can see the beta listing.
3. Provide review notes describing the scope of the beta; Garmin still runs automated checks.
4. To promote the changes, submit a new build (or re-upload the same binary) with a standard version name that does **not** start with `BETA`.

**Use it when** you need extended feedback from a closed group without exposing the build to the full user base.

## Tips for both flows

- Keep changelog context in the review note to speed up Garmin’s review.
- Verify that testers can install from the store; only listed accounts have access.
- After launch, double-check that future submissions don’t accidentally retain `BETA` prefixes or “Do not approve” notes.
