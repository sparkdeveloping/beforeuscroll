import type { Metadata } from 'next';
import { LegalPage } from '@/components/LegalPage';
import { site } from '@/lib/site';

export const metadata: Metadata = { title: 'Privacy Policy' };

export default function PrivacyPage() {
  return (
    <LegalPage title="Privacy Policy" subtitle="Last updated: June 14, 2026">
      <p>BeforeUScroll is built to help you guard your attention with Scripture and prayer. The app is designed to collect as little personal information as possible.</p>
      <h2>Information we do not collect</h2>
      <p>BeforeUScroll does not read your messages, social feeds, app contents, browsing content, photos, screen contents, or keyboard input. BeforeUScroll does not sell personal data and does not include third-party advertising.</p>
      <h2>Screen Time selections</h2>
      <p>When you choose apps or websites to protect, iOS represents those choices using Apple Screen Time tokens. BeforeUScroll stores those tokens locally on your device and in the app group used by its Screen Time extensions so protection can work reliably.</p>
      <h2>Notifications</h2>
      <p>If you allow notifications, BeforeUScroll may send utility notifications such as Flame low, Flame expired, or pause-ready reminders. Notification permission is optional.</p>
      <h2>Purchases</h2>
      <p>Premium purchases are handled by Apple StoreKit. BeforeUScroll receives purchase status from Apple so it can unlock premium features, but payment details are handled by Apple.</p>
      <h2>Support</h2>
      <p>If you contact support, we will receive the information you choose to send, such as your email address and message.</p>
      <h2>Children</h2>
      <p>BeforeUScroll is a voluntary faith-based productivity tool. It is not intended to collect personal information from children.</p>
      <h2>Changes</h2>
      <p>We may update this Privacy Policy as the app changes. The latest version will be available at this page.</p>
      <h2>Contact</h2>
      <p>Questions can be sent to <a href={`mailto:${site.supportEmail}`}>{site.supportEmail}</a>.</p>
    </LegalPage>
  );
}
