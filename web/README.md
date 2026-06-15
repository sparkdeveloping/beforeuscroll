# BeforeUScroll Landing Site

A polished Next.js + Tailwind CSS + Framer Motion landing page for BeforeUScroll.

## Routes

- `/` — marketing landing page
- `/privacy` — Privacy Policy
- `/terms` — Terms & Conditions
- `/support` — Support page

## Run locally

```bash
npm install
npm run dev
```

Then open `http://localhost:3000`.

## Deploy to Vercel

1. Push this folder to GitHub.
2. Import the project in Vercel.
3. Set the production domain to `beforeuscroll.vercel.app` or your custom domain.
4. Add environment variables if needed:

```bash
NEXT_PUBLIC_APP_STORE_URL=https://apps.apple.com/app/your-app-id
NEXT_PUBLIC_SUPPORT_EMAIL=your-support-email@example.com
```

If `NEXT_PUBLIC_APP_STORE_URL` is empty, the App Store button still renders but points to `#download`. Update it before launch.

## Legal links for the iOS app

Use these in the app:

- Privacy: `https://beforeuscroll.vercel.app/privacy`
- Terms: `https://beforeuscroll.vercel.app/terms`
- Support: `https://beforeuscroll.vercel.app/support`

## Assets

The site includes the provided app screenshots and the flame logo asset under `public/brand` and `public/screens`.

## Notes

The privacy and terms pages are starter text tailored to the current BeforeUScroll behavior described in the app. Review with a legal professional before App Store submission if possible.
