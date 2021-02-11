module myconfig

fn site_config(mut c ConfigRoot) {
	c.sites << SiteConfig{
		name: 'www_threefold_cloud'
		alias: 'cloud'
		url: 'https://github.com/threefoldfoundation/www_threefold_cloud'
		cat: SiteCat.web
	}
	c.sites << SiteConfig{
		name: 'www_threefold_farming'
		alias: 'farming'
		url: 'https://github.com/threefoldfoundation/www_threefold_farming'
		cat: SiteCat.web
	}
	c.sites << SiteConfig{
		name: 'www_threefold_twin'
		alias: 'twin'
		url: 'https://github.com/threefoldfoundation/www_threefold_twin'
		cat: SiteCat.web
	}
	c.sites << SiteConfig{
		name: 'www_threefold_marketplace'
		alias: 'marketplace'
		url: 'https://github.com/threefoldfoundation/www_threefold_marketplace'
		cat: SiteCat.web
	}
	c.sites << SiteConfig{
		name: 'www_conscious_internet'
		alias: 'conscious_internet'
		url: 'https://github.com/threefoldfoundation/www_conscious_internet'
		cat: SiteCat.web
	}
	c.sites << SiteConfig{
		name: 'www_threefold_tech'
		alias: 'tech'
		url: 'https://github.com/threefoldtech/www_threefold_tech'
		cat: SiteCat.web
	}
	c.sites << SiteConfig{
		name: 'www_examplesite'
		alias: 'examplesite'
		url: 'https://github.com/threefoldfoundation/www_examplesite'
		cat: SiteCat.web
	}
	c.sites << SiteConfig{
		name: 'info_foundation'
		alias: 'foundation'
		url: 'https://github.com/threefoldfoundation/info_foundation'
	}
	c.sites << SiteConfig{
		name: 'info_tfgrid_sdk'
		alias: 'manual'
		url: 'https://github.com/threefoldfoundation/info_tfgrid_sdk'
	}
	c.sites << SiteConfig{
		name: 'info_legal'
		alias: 'legal'
		url: 'https://github.com/threefoldfoundation/info_legal'
	}
	c.sites << SiteConfig{
		name: 'info_cloud'
		alias: 'cloud'
		url: 'https://github.com/threefoldfoundation/info_cloud'
	}
	c.sites << SiteConfig{
		name: 'info_tftech'
		alias: 'tftech'
		url: 'https://github.com/threefoldtech/info_tftech'
	}
	c.sites << SiteConfig{
		name: 'info_digitaltwin'
		alias: 'twin'
		url: 'https://github.com/threefoldfoundation/info_digitaltwin.git'
	}
	c.sites << SiteConfig{
		name: 'data_threefold'
		alias: 'data'
		url: 'https://github.com/threefoldfoundation/data_threefold'
		cat: SiteCat.data
	}
}
