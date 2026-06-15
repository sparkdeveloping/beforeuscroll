'use client';

import { motion, useScroll, useTransform } from 'framer-motion';
import { ArrowRight, Bell, Flame, ShieldCheck } from 'lucide-react';
import { BrandMark } from './BrandMark';
import { PhoneMockup } from './PhoneMockup';
import { site } from '@/lib/site';

export function Hero() {
  const { scrollYProgress } = useScroll();
  const yA = useTransform(scrollYProgress, [0, 0.35], [0, -70]);
  const yB = useTransform(scrollYProgress, [0, 0.35], [30, -25]);

  return (
    <section className="relative isolate overflow-hidden px-4 pb-20 pt-32 md:px-8 md:pb-28 md:pt-40">
      <div className="absolute inset-0 -z-10 bg-ember-radial" />
      <motion.div className="absolute left-1/2 top-24 -z-10 h-[520px] w-[520px] -translate-x-1/2 rounded-full bg-ember/15 blur-3xl" animate={{ opacity: [0.45, 0.75, 0.45], scale: [1, 1.08, 1] }} transition={{ duration: 7, repeat: Infinity, ease: 'easeInOut' }} />

      <div className="mx-auto grid max-w-7xl items-center gap-14 lg:grid-cols-[1.02fr_.98fr]">
        <div className="text-center lg:text-left">
          <motion.div initial={{ opacity: 0, y: 14 }} animate={{ opacity: 1, y: 0 }} transition={{ duration: 0.55 }} className="mb-7 inline-flex items-center gap-2 rounded-full border border-white/10 bg-white/8 px-4 py-2 text-sm font-extrabold text-peach backdrop-blur-xl">
            <Flame className="h-4 w-4 text-ember" /> Scripture before the scroll gets you
          </motion.div>

          <motion.div initial={{ opacity: 0, scale: 0.96 }} animate={{ opacity: 1, scale: 1 }} transition={{ delay: 0.05, duration: 0.6 }} className="mb-8 flex justify-center lg:justify-start">
            <BrandMark size="xl" />
          </motion.div>

          <motion.h1 initial={{ opacity: 0, y: 18 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: 0.1, duration: 0.65 }} className="mx-auto max-w-4xl text-balance text-5xl font-black leading-[0.94] tracking-[-0.055em] text-cream md:text-7xl lg:mx-0 lg:text-8xl">
            Keep your Flame alive before you scroll.
          </motion.h1>

          <motion.p initial={{ opacity: 0, y: 18 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: 0.2, duration: 0.65 }} className="mx-auto mt-7 max-w-2xl text-balance text-lg font-bold leading-8 text-cream/64 md:text-xl lg:mx-0">
            BeforeUScroll is a Christian app blocker where Scripture and prayer add intentional time. When your Flame burns out, protected apps lock again.
          </motion.p>

          <motion.div initial={{ opacity: 0, y: 18 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: 0.28, duration: 0.65 }} className="mt-9 flex flex-col items-center gap-3 sm:flex-row lg:justify-start">
            <a id="download" href={site.appStoreUrl} className="group inline-flex w-full items-center justify-center gap-3 rounded-full bg-cta px-8 py-5 text-lg font-black text-black shadow-ember transition hover:scale-[1.015] sm:w-auto">
              Download on the App Store <ArrowRight className="h-5 w-5 transition group-hover:translate-x-1" />
            </a>
            <a href="#how" className="inline-flex w-full items-center justify-center rounded-full border border-white/12 bg-white/8 px-8 py-5 text-lg font-black text-cream backdrop-blur-xl transition hover:bg-white/12 sm:w-auto">
              See how it works
            </a>
          </motion.div>

          <motion.div initial={{ opacity: 0 }} animate={{ opacity: 1 }} transition={{ delay: 0.45 }} className="mt-10 grid gap-3 text-left text-sm font-bold text-cream/70 sm:grid-cols-3">
            <div className="glass rounded-3xl p-4"><ShieldCheck className="mb-2 h-5 w-5 text-green-300" /> Uses Apple Screen Time APIs</div>
            <div className="glass rounded-3xl p-4"><Bell className="mb-2 h-5 w-5 text-peach" /> Optional Flame notifications</div>
            <div className="glass rounded-3xl p-4"><Flame className="mb-2 h-5 w-5 text-ember" /> Scripture + prayer recharges</div>
          </motion.div>
        </div>

        <div className="relative min-h-[640px] lg:min-h-[760px]">
          <motion.div style={{ y: yA }} className="absolute left-0 top-10 z-10 w-[52%] rotate-[-5deg] md:left-10 lg:left-0">
            <PhoneMockup src="/screens/home-flame.webp" alt="BeforeUScroll Flame home screen" priority />
          </motion.div>
          <motion.div style={{ y: yB }} className="absolute right-0 top-0 w-[52%] rotate-[6deg] md:right-12 lg:right-0">
            <PhoneMockup src="/screens/scripture-question.webp" alt="BeforeUScroll Scripture question screen" />
          </motion.div>
          <motion.div initial={{ opacity: 0, y: 28 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: 0.42, duration: 0.7 }} className="absolute bottom-4 left-1/2 z-20 w-[46%] -translate-x-1/2 rotate-[1deg]">
            <PhoneMockup src="/screens/prayer-mode.webp" alt="BeforeUScroll Prayer Mode screen" />
          </motion.div>
        </div>
      </div>
    </section>
  );
}
