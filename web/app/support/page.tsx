import type { Metadata } from 'next';
import { Mail, ShieldCheck, Flame, HelpCircle } from 'lucide-react';
import { LegalPage } from '@/components/LegalPage';
import { site } from '@/lib/site';

export const metadata: Metadata = { title: 'Support' };

export default function SupportPage() {
  return (
    <LegalPage title="Support" subtitle="Get help with setup, protection, purchases, or app review questions.">
      <div className="not-prose grid gap-4 md:grid-cols-2">
        <a href={`mailto:${site.supportEmail}`} className="glass rounded-3xl p-5 no-underline transition hover:bg-white/10">
          <Mail className="mb-4 h-7 w-7 text-gold" />
          <h2 className="m-0 text-2xl font-black text-cream">Email support</h2>
          <p className="mt-2 font-bold text-cream/60">{site.supportEmail}</p>
        </a>
        <div className="glass rounded-3xl p-5">
          <ShieldCheck className="mb-4 h-7 w-7 text-green-300" />
          <h2 className="m-0 text-2xl font-black text-cream">Screen Time setup</h2>
          <p className="mt-2 font-bold text-cream/60">Make sure Screen Time permission is allowed and at least one app is selected.</p>
        </div>
      </div>
      <h2>Common questions</h2>
      <h3>My protected app is not locking.</h3>
      <p>Open BeforeUScroll, check that Protection is active, and confirm at least one app is selected under Edit Apps. If your Flame has time remaining, selected apps may stay open until the Flame burns out.</p>
      <h3>Does BeforeUScroll read app content?</h3>
      <p>No. The app uses Apple Screen Time tokens for selected apps and websites. It does not read app feeds, messages, screen content, or browsing content.</p>
      <h3>How do I cancel Premium?</h3>
      <p>Subscriptions are managed through Apple. Open the App Store app, tap your account, choose Subscriptions, and manage BeforeUScroll there.</p>
      <h3>What should I include in a support email?</h3>
      <p>Please include your device model, iOS version, what you expected, what happened, and screenshots if helpful.</p>
    </LegalPage>
  );
}
