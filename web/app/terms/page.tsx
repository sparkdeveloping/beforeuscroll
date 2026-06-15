import type { Metadata } from 'next';
import { LegalPage } from '@/components/LegalPage';
import { site } from '@/lib/site';

export const metadata: Metadata = { title: 'Terms & Conditions' };

export default function TermsPage() {
  return (
    <LegalPage title="Terms & Conditions" subtitle="Last updated: June 14, 2026">
      <p>By using BeforeUScroll, you agree to these Terms. If you do not agree, do not use the app.</p>
      <h2>Purpose of the app</h2>
      <p>BeforeUScroll is a voluntary Scripture-based focus tool. It helps users choose apps to protect, recharge a Flame through Scripture and prayer, and create intentional time before opening distracting apps.</p>
      <h2>No guarantee</h2>
      <p>BeforeUScroll depends on Apple Screen Time APIs and system behavior. We work to make protection reliable, but no app blocker can guarantee that every distraction, website, app, or device behavior will always be blocked in every situation.</p>
      <h2>Faith content</h2>
      <p>The app includes Scripture-based prompts and prayer features. It is intended as a supportive tool, not pastoral counseling, medical care, therapy, or crisis support.</p>
      <h2>Premium features</h2>
      <p>Some features may require an auto-renewable subscription or other in-app purchase. Purchases are handled through Apple. Subscriptions renew unless cancelled according to Apple’s App Store subscription rules.</p>
      <h2>Acceptable use</h2>
      <p>You agree not to misuse the app, reverse engineer it, interfere with its services, or use it for unlawful purposes.</p>
      <h2>Limitation of liability</h2>
      <p>BeforeUScroll is provided as-is. To the fullest extent permitted by law, we are not liable for indirect, incidental, or consequential damages related to use of the app.</p>
      <h2>Contact</h2>
      <p>Questions about these Terms can be sent to <a href={`mailto:${site.supportEmail}`}>{site.supportEmail}</a>.</p>
    </LegalPage>
  );
}
