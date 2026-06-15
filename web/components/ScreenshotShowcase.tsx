'use client';

import { motion } from 'framer-motion';
import { screenshotSet } from '@/lib/site';
import { PhoneMockup } from './PhoneMockup';
import { SectionHeading } from './SectionHeading';

export function ScreenshotShowcase() {
  return (
    <section id="screens" className="overflow-hidden px-4 py-20 md:px-8 md:py-28">
      <div className="mx-auto max-w-7xl">
        <SectionHeading eyebrow="Screens" title="Designed to feel like a sacred interruption, not a punishment screen." />
      </div>
      <div className="relative -mx-4 mt-10 flex gap-6 overflow-x-auto px-4 pb-8 [scrollbar-width:none] md:-mx-8 md:px-8">
        {screenshotSet.map((screen, i) => (
          <motion.div key={screen.src} initial={{ opacity: 0, y: 30, rotate: i % 2 ? 2 : -2 }} whileInView={{ opacity: 1, y: 0, rotate: i % 2 ? 1 : -1 }} viewport={{ once: true }} transition={{ delay: i * 0.04, duration: 0.55 }} className="w-[260px] shrink-0 md:w-[310px]">
            <PhoneMockup src={screen.src} alt={screen.alt} />
            <p className="mt-4 text-center text-sm font-black uppercase tracking-[0.2em] text-gold/80">{screen.label}</p>
          </motion.div>
        ))}
      </div>
    </section>
  );
}
