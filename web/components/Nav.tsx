import Link from 'next/link';
import { BrandMark } from './BrandMark';
import { site } from '@/lib/site';

export function Nav() {
  return (
    <header className="fixed inset-x-0 top-0 z-50 px-4 py-4 md:px-8">
      <nav className="mx-auto flex max-w-7xl items-center justify-between rounded-full border border-white/10 bg-night/55 px-4 py-3 shadow-soft backdrop-blur-2xl">
        <Link href="/" className="flex items-center gap-3">
          <BrandMark size="sm" glow={false} />
          <span className="text-lg font-black tracking-tight text-cream">BeforeUScroll</span>
        </Link>
        <div className="hidden items-center gap-6 text-sm font-bold text-cream/70 md:flex">
          <a href="#how">How it works</a>
          <a href="#screens">Screens</a>
          <a href="#privacy">Privacy</a>
          <a href="#download" className="rounded-full bg-cream px-4 py-2 text-night transition hover:bg-peach">Download</a>
        </div>
        <a href={site.appStoreUrl} className="rounded-full bg-cta px-4 py-2 text-sm font-black text-black shadow-ember md:hidden">Get App</a>
      </nav>
    </header>
  );
}
