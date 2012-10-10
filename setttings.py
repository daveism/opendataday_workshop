"""
Copy this to settings.py, uncomment the various settings, and
edit them as desired.
"""

from ebpub.settings_default import *

########################
# CORE DJANGO SETTINGS #
########################

DEBUG=True
TIME_ZONE = 'US/Eastern'

PROJECT_DIR = os.path.normpath(os.path.dirname(__file__))
INSTALLED_APPS = ('myblock', ) + INSTALLED_APPS
TEMPLATE_DIRS = (os.path.join(PROJECT_DIR, 'templates'), ) + TEMPLATE_DIRS
ROOT_URLCONF = 'myblock.urls'


DATABASES = {
    'default': {
        'NAME': 'openblock_myblock',
        'USER': 'openblock',
        'PASSWORD': '',
        'ENGINE': 'django.contrib.gis.db.backends.postgis',
        'OPTIONS': {},
        'HOST': '',
        'PORT': '',
        'TEST_NAME': 'test_openblock',
    },
}

#########################
# CUSTOM EBPUB SETTINGS #
#########################

# The domain for your site.
EB_DOMAIN = 'localhost'

# This is the short name for your city, e.g. "chicago".
SHORT_NAME = 'asheville'

# Set both of these to distinct, secret strings that include two instances
# of '%s' each. Example: 'j8#%s%s' -- but don't use that, because it's not
# secret.  And don't check the result in to a public code repository
# or otherwise put it out in the open!
PASSWORD_CREATE_SALT = 'mysecretsalt%s'
PASSWORD_RESET_SALT = 'resetthesecret%s'

# You probably don't need to override STATIC_ROOT or STATIC_URL, the
# settings in settings.py should work out of the box.
# You may want to override MEDIA_ROOT (where to upload user-uploaded files)
# and MEDIA_URL (where to serve them).

# This is used as a "From:" in e-mails sent to users.
GENERIC_EMAIL_SENDER = 'openblock@' + EB_DOMAIN

# Filesystem location of scraper log.
SCRAPER_LOGFILE_NAME = '/tmp/scraperlog_myblock'

# If this cookie is set with the given value, then the site will give the user
# staff privileges (including the ability to view non-public schemas).
STAFF_COOKIE_NAME = 'obstaff_myblock'
STAFF_COOKIE_VALUE = 'coastaff'

# What LocationType to redirect to when viewing /locations.
DEFAULT_LOCTYPE_SLUG='neighborhoods'

# What kinds of news to show on the homepage.
# This is one or more Schema slugs.
HOMEPAGE_DEFAULT_NEWSTYPES = [u'news-articles']

# How many days of news to show on the homepage, place detail view,
# and elsewhere.
DEFAULT_DAYS = 7

# Where to center citywide maps, eg. on homepage.
DEFAULT_MAP_CENTER_LON = -82.548525
DEFAULT_MAP_CENTER_LAT =  35.595564
DEFAULT_MAP_ZOOM = 12

# Edit this if you want to control where
# scraper scripts will put their HTTP cache.
# (Warning, don't put it in a directory encrypted with ecryptfs
# or you'll likely have "File name too long" errors.)
HTTP_CACHE = '/tmp/openblock_scraper_cache_myblock'

# Metros. You almost certainly only want one dictionary in this list.
# See the configuration docs for more info.
METRO_LIST = (
    {
        # Extent of the region, as a longitude/latitude bounding box.
        'extent': (-82.890418, 35.400321, -82.162361, 35.836492),

        # Whether this region should be displayed to the public.
        'is_public': True,

        # Set this to True if the region has multiple cities.
        # You will also need to set 'city_location_type'.
        'multiple_cities': True,

        # The major city in the region.
        'city_name': 'ASHEVILLE',

        # The SHORT_NAME in the settings file.
        'short_name': 'asheville',

        # The name of the region, as opposed to the city (e.g., "Miami-Dade" instead of "Miami").
        'metro_name': 'Asheville',

        # USPS abbreviation for the state.
        'state': 'NC',

        # Full name of state.
        'state_name': 'NORTH CAROLINA',

        # Time zone, as required by Django's TIME_ZONE setting.
        'time_zone': TIME_ZONE,

        # Slug of an ebpub.db.LocationType that represents cities.
        # Only needed if multiple_cities = True.
        'city_location_type': 'cities',
    },
)

CACHES = {
    # Use whatever Django cache backend you like;
    # FileBasedCache is a reasonable choice for low-budget, memory-constrained
    # hosting environments.
    'default': {
        'BACKEND': 'django.core.cache.backends.filebased.FileBasedCache',
        'LOCATION': '/tmp/myblock_cache'
          # # Use this to disable caching.
          #'BACKEND': 'django.core.cache.backends.dummy.DummyCache',
    }
}

if DEBUG:
    for _name in required_settings:
        if not _name in globals():
            raise NameError("Required setting %r was not defined in settings.py or settings_default.py" % _name)
u
