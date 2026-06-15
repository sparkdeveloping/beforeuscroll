import { Nav } from '@/components/Nav';
import { Hero } from '@/components/Hero';
import { HowItWorks } from '@/components/HowItWorks';
import { FlameMechanic } from '@/components/FlameMechanic';
import { ScreenshotShowcase } from '@/components/ScreenshotShowcase';
import { FeatureGrid } from '@/components/FeatureGrid';
import { Premium } from '@/components/Premium';
import { FAQ } from '@/components/FAQ';
import { Footer } from '@/components/Footer';

export default function HomePage() {
  return (
    <main>
      <Nav />
      <Hero />
      <HowItWorks />
      <FlameMechanic />
      <ScreenshotShowcase />
      <FeatureGrid />
      <Premium />
      <FAQ />
      <Footer />
    </main>
  );
}
