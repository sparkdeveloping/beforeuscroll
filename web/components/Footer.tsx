import Link from 'next/link';
import { BrandMark } from './BrandMark';
import { site } from '@/lib/site';

export function Footer() {
  return (
    <footer className="px-4 pb-10 pt-16 md:px-8">
      <div className="mx-auto max-w-7xl rounded-[2rem] border border-white/10 bg-white/[0.04] p-8">
        <div className="flex flex-col justify-between gap-8 md:flex-row md:items-center">
          <div className="flex items-center gap-4">
            <BrandMark size="md" glow={false} />
            <div>
              <p className="text-xl font-black text-cream">BeforeUScroll</p>
              <p className="text-sm font-bold text-cream/50">Scripture before the scroll.</p>
            </div>
          </div>
          <div className="flex flex-wrap gap-5 text-sm font-bold text-cream/58">
            <Link href={site.links.privacy}>Privacy</Link>
            <Link href={site.links.terms}>Terms</Link>
            <Link href={site.links.support}>Support</Link>
            <a href={`mailto:${site.supportEmail}`}>Contact</a>
          </div>
        </div>
        <p className="mt-8 text-xs font-bold leading-6 text-cream/36">© {new Date().getFullYear()} BeforeUScroll. BeforeUScroll is a voluntary faith-based Screen Time tool. Apple, App Store, and Screen Time are trademarks of Apple Inc.</p>
      </div>
    </footer>
  );
}
