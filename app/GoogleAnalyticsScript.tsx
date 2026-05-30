import Script from "next/script";

type GoogleAnalyticsScriptProps = {
  nonce?: string | null;
};

export default function GoogleAnalyticsScript({ nonce }: GoogleAnalyticsScriptProps) {
  return (
    <>
        <Script
          async
          nonce={nonce ?? undefined}
          src="https://www.googletagmanager.com/gtag/js?id=G-VRKRLX390T"
        />
        <Script nonce={nonce ?? undefined} strategy='lazyOnload'>
        {` window.dataLayer = window.dataLayer || [];
        function gtag(){dataLayer.push(arguments);}
        gtag('js', new Date());

        gtag('config', 'G-VRKRLX390T'); `}
        </Script>
    </>
  )
}
