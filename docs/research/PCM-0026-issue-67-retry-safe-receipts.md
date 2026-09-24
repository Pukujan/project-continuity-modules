# PCM-0026 — Retry-safe receipt research

This note serves [issue #67](https://github.com/Pukujan/project-continuity-modules/issues/67) / PCM-0026. It records what a retry-safe GitHub receipt publisher must not assume. It is not implementation proof, and it does not close issue #67 or parent issue #53.

Astra accepted the merged PCM-0025 policy as the prerequisite and reserved `task/PCM-0026-github-receipts`. Staff wrote this note from copies Astra fetched on 2026-09-24 while that planning process was idle and had not created the file. Astra still verifies the contract before publisher code starts.

## Problem

A checkpoint receipt is created with a POST. If GitHub accepts the comment and the response is lost, a blind retry can create a second comment. The fetched GitHub issue-comment documentation does not document an idempotency key for that POST.

## Evidence

Accessed 2026-09-24. Raw copies and hashes are in the private research folder named in the staff provenance index. These claims are limited to those copies.

1. Creating an issue comment triggers notifications, and creating content too quickly may hit a secondary rate limit. The fetched comments page does not document an idempotency key. Source: [GitHub REST issue comments](https://docs.github.com/en/rest/issues/comments), copy SHA-256 `8324748dbbcd6107b796292552e0df4f2d583612065162735a02502d75e6d055`.

2. Clients should send REST requests serially. If `retry-after` is present, wait that many seconds. Otherwise wait at least one minute, then back off, and stop after a bounded number of retries. Source: [Best practices for using the REST API](https://docs.github.com/en/rest/using-the-rest-api/best-practices-for-using-the-rest-api), copy SHA-256 `4eddda65572223fe47f676631870e4adc08c976e3940cfd52387bed8eb51f7f1`.

3. A client should not automatically retry a non-idempotent method unless it knows the request is actually idempotent or can detect that the original request was never applied. Checking the target after a failed connection is the documented recovery example. A proxy must not automatically retry non-idempotent requests. Source: [RFC 9110](https://www.rfc-editor.org/rfc/rfc9110.html), section 9.2.2, copy SHA-256 `d431760660ea44e130f6e919dab216df2d0b3a490567a98089267523368fe1e5`.

## Contract this evidence supports

A lost POST response is not proof that the receipt is absent. Recovery lists remote comments and matches the receipt marker. If that lookup is incomplete, paginated without a finished scan, or ambiguous because another writer may have posted, the publisher stops visibly and does not post again. Manual receipts stay mandatory until that behavior is tested. No scheduler and no second GitHub account are part of this slice.

## Unknown

Whether GitHub adds an idempotency key to this endpoint after 2026-09-24 was not re-checked beyond the fetched copy. That remains unknown until the copy is refreshed.
