AK3OR DIGITAL HUB — QUICK SETUP

FILES
- index.html: complete single-file website (HTML, CSS, JavaScript)
- supabase-setup.sql: database schema, storage bucket, and security policies

1. CREATE YOUR SUPABASE PROJECT
- Create a project at https://supabase.com.
- Open SQL Editor, paste all of supabase-setup.sql, and run it.
- Open Project Settings > API. Copy the Project URL and anon/public key.

2. CONNECT THE WEBSITE
- Open index.html in a code editor.
- Near the bottom, find:
    const SUPABASE_URL = 'YOUR_SUPABASE_URL';
    const SUPABASE_ANON_KEY = 'YOUR_SUPABASE_ANON_KEY';
- Replace those two placeholders with your Supabase Project URL and anon/public key.
- Never use the service_role/secret key in index.html.

3. CREATE YOUR OWNER ACCOUNT
- In Supabase Dashboard > Authentication > Users, create your account with your own email and a strong password.
- Copy that user's UUID.
- In SQL Editor, run this command after replacing the UUID:
    update public.profiles set is_admin = true where id = 'YOUR-USER-UUID';
- In Authentication settings, turn off public sign-ups after your owner account is created.
- The site checks the profiles.is_admin value before showing the private dashboard. Database RLS and Storage policies independently enforce owner permissions.

4. PUBLISH ON GITHUB PAGES
- Create a GitHub repository.
- Upload index.html to the repository root (and optionally keep this README and SQL file in the repo; they are not needed by the live website).
- Go to repository Settings > Pages.
- Under Build and deployment, choose Deploy from a branch, select main and /(root), then Save.
- Open the Pages URL after deployment.

5. TEST
- Open the public site in a private/incognito browser. Visitors should only see published records and cannot edit or upload.
- Sign in using your owner account. Try creating a post, uploading a file, adding an application, and adding social links.
- Publish files/apps only when you have permission to distribute them. Use official App Store/TestFlight links for iOS apps.

IMPORTANT LIMITATIONS
- GitHub Pages is static hosting. Supabase provides authentication, database, and file storage.
- The frontend is a single index.html, but it requires an internet connection for Google Fonts, the Supabase JavaScript client, and your Supabase project.
- Uploaded files are stored in a public bucket to allow visitor downloads. Anyone who has a public file URL can download that file. Do not upload private or sensitive files.
- The upload size limit in the supplied SQL is 500 MiB; your Supabase plan and project storage settings may impose lower limits.
- This starter uses URL fields for post cover images and app icons. Host those images in a public image service/bucket and paste their public URLs.
- Edit in the admin panel currently edits the title and description. To change other fields, delete the record and create it again or extend the form.
- No website can verify that every external installer/store link is safe. Only add links you trust.

PRELOADED APP CATALOG
- The Apps page now includes 30 curated Windows PC app shortcuts and 10 mobile app listings.
- Each Windows shortcut has a publisher download page and a copyable WinGet download command.
- To download a PC installer using WinGet, copy the command from the card and paste it into Windows Terminal or PowerShell. Example: winget download --id Microsoft.PowerToys -e --source winget
- The Apps page links to the WinGet community catalogue, which listed 4,315 package entries when checked on 18 November 2026. That directory is maintained separately and can change over time; it is not a bundle of installers hosted by AK3OR.
- WinGet availability and individual package system requirements vary. Microsoft documents WinGet support for Windows 10 version 1809 and later and Windows 11. Users may need Microsoft's App Installer component.
- The 10 mobile entries open official Google Play and Apple App Store listings. AK3OR does not host mobile installation packages.

CATALOG REFERENCES
- WinGet package catalogue: https://winget.run/search
- Microsoft WinGet overview: https://learn.microsoft.com/en-us/windows/package-manager/winget/
- Microsoft WinGet download command: https://learn.microsoft.com/en-us/windows/package-manager/winget/download


SOCIAL LINKS
- The public site has these five links preloaded in preview mode: Instagram @or7ka, TikTok @ak3or, YouTube @ak3or, GitHub @ak3or, and your Discord invite.
- If Supabase is configured, re-run the updated supabase-setup.sql in the Supabase SQL Editor to add the five links to the social_links table. The seed statements update an existing matching platform or insert it when missing, without creating another row for that platform.
- You can manage the links later from the private dashboard > Social links.
