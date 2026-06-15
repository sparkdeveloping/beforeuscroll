import type { Metadata, Viewport } from 'next';
import './globals.css';
import { site } from '@/lib/site';

export const metadata: Metadata = {
  metadataBase: new URL(site.url),
  title: {
    default: 'BeforeUScroll — Scripture before the scroll',
    template: '%s | BeforeUScroll'
  },
  description: 'A Christian app blocker where Scripture and prayer keep your Flame alive. When it burns out, protected apps lock again.',
  openGraph: {
    title: 'BeforeUScroll',
    description: 'Scripture and prayer before the scroll gets you.',
    url: site.url,
    siteName: 'BeforeUScroll',
    images: [{ url: '/og.png', width: 1200, height: 630 }],
    locale: 'en_US',
    type: 'website'
  },
  twitter: {
    card: 'summary_large_image',
    title: 'BeforeUScroll',
    description: 'Scripture and prayer before the scroll gets you.',
    images: ['/og.png']
  },
  icons: {
    icon: '/favicon.png',
    apple: '/apple-touch-icon.png'
  }
};

export const viewport: Viewport = {
  themeColor: '#0d0712',
  width: 'device-width',
  initialScale: 1
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en">
      <body>{children}</body>
    </html>
  );
}
