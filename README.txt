AK3OR DIGITAL HUB — GITHUB PAGES + SUPABASE SETUP

WHAT IS INCLUDED
- index.html: the complete single-file website (HTML, CSS, and JavaScript).
- supabase-setup.sql: database tables, policies, and storage setup.
- owner-admin-setup.sql: promotes exactly one Supabase user as the owner.
- .github/workflows/deploy.yml: GitHub Actions workflow that injects Supabase settings at deployment and publishes the site to GitHub Pages.

1. CREATE / CONFIGURE SUPABASE
1) Create or open your project at https://supabase.com/dashboard.
2) Open SQL Editor, paste the complete supabase-setup.sql file, and run it.
3) In the Supabase dashboard, open Connect or Project Settings > API Keys.
4) Copy the Project URL and the publishable key (starts with sb_publishable_).
5) Never use a secret key or service_role key in the website.

2. ADD THE SETTINGS TO GITHUB ACTIONS
1) Open your GitHub repository.
2) Go to Settings > Secrets and variables > Actions.
3) Open the Variables tab (not the Secrets tab), then click New repository variable.
4) Add this variable:
   Name: SUPABASE_URL
   Value: your Supabase Project URL, for example https://your-project-ref.supabase.co
5) Add a second repository variable:
   Name: SUPABASE_PUBLISHABLE_KEY
   Value: your Supabase publishable key (sb_publishable_...).
6) Save both variables.

IMPORTANT: A Supabase publishable key is designed for browser use and is not a password. It will be included in the generated public website. Security must come from Supabase Row Level Security (RLS) and Storage policies. Do NOT add the Supabase secret/service_role key anywhere in GitHub variables, the HTML, or the workflow.

3. UPLOAD THE WEBSITE FILES TO GITHUB
- Put index.html in the repository root (same level as this README).
- Put supabase-setup.sql in the repository root.
- Put the deploy.yml file at .github/workflows/deploy.yml (keep the folders and spelling exactly as shown).
- Commit and push these files to the main branch.

4. ENABLE GITHUB PAGES WITH ACTIONS
1) In the repository, open Settings > Pages.
2) Under Build and deployment, set Source to GitHub Actions.
3) Push a commit to main, or open the Actions tab and run "Deploy AK3OR Digital Hub to GitHub Pages" manually.
4) Wait for the workflow to complete successfully. Open the Pages URL shown in the deployment job.

5. CREATE YOUR OWNER ACCOUNT
1) In Supabase Dashboard > Authentication > Users, create your account using your email and a strong password.
2) Copy that user's UUID.
3) In Supabase SQL Editor, run this command after replacing the UUID:
   update public.profiles set is_admin = true where id = 'YOUR-USER-UUID';
4) Turn off public sign-ups in Supabase Authentication settings after creating your owner account.
5) The site checks profiles.is_admin before displaying the admin dashboard. Database RLS and Storage policies must independently enforce owner permissions.

HOW THE ENVIRONMENT SETTINGS WORK
GitHub Pages is static hosting. It does not provide runtime environment variables to browser JavaScript and it does not run a server-side .env file. This package uses GitHub Actions repository Variables during deployment to replace placeholders in a generated copy of index.html. The source file in your repository stays free of your project settings. The generated site is public, so the Supabase URL and publishable key can be seen by visitors; this is normal. RLS is what protects your data.

TROUBLESHOOTING
- If the Actions job says variables are missing, check the exact names: SUPABASE_URL and SUPABASE_PUBLISHABLE_KEY.
- If the Actions tab shows no deployment, verify Pages > Source is set to GitHub Actions and the workflow file is under .github/workflows/.
- If visitors can see the site but content/admin features do not work, check that supabase-setup.sql was run in the correct Supabase project and verify RLS policies.
- Do not paste a Supabase secret/service_role key into any browser-facing configuration.

OTHER
- The site uses external font, icon, and Supabase CDN resources, so visitors need an internet connection.
- Uploaded files are intended for public downloads. Do not upload private or sensitive files.
- Only publish software and files you have permission to distribute. For iOS apps, use official App Store/TestFlight links.


PRIVATE ADMIN DASHBOARD
- Open the website and click Owner Login in the top navigation, or visit your GitHub Pages URL followed by #admin (for example https://YOUR-USERNAME.github.io/YOUR-REPOSITORY/#admin).
- Sign in with the one Supabase Auth account whose public.profiles row has is_admin = true.
- The dashboard includes overview, create post, upload file, add application, manage/publish/unpublish/delete content, and social links.
- All other signed-in accounts are rejected. New accounts are not administrators by default.
- The admin overlay is a convenience only; authorization is enforced again by Supabase RLS for table writes and Storage uploads/deletes.
- The owner can see drafts and hidden social links; public visitors only receive published/visible rows.
