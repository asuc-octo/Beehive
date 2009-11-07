
***REMOVED*** A Site key gives additional protection against a dictionary attack if your
***REMOVED*** DB is ever compromised.  With no site key, we store
***REMOVED***   DB_password = hash(user_password, DB_user_salt)
***REMOVED*** If your database were to be compromised you'd be vulnerable to a dictionary
***REMOVED*** attack on all your stupid users' passwords.  With a site key, we store
***REMOVED***   DB_password = hash(user_password, DB_user_salt, Code_site_key)
***REMOVED*** That means an attacker needs access to both your site's code *and* its
***REMOVED*** database to mount an "offline dictionary attack.":http://www.dwheeler.com/secure-programs/Secure-Programs-HOWTO/web-authentication.html
***REMOVED*** 
***REMOVED*** It's probably of minor importance, but recommended by best practices: 'defense
***REMOVED*** in depth'.  Needless to say, if you upload this to github or the youtubes or
***REMOVED*** otherwise place it in public view you'll kinda defeat the point.  Your users'
***REMOVED*** passwords are still secure, and the world won't end, but defense_in_depth -= 1.
***REMOVED*** 
***REMOVED*** Please note: if you change this, all the passwords will be invalidated, so DO
***REMOVED*** keep it someplace secure.  Use the random value given or type in the lyrics to
***REMOVED*** your favorite Jay-Z song or something; any moderately long, unpredictable text.
REST_AUTH_SITE_KEY         = '2aa6124dbd6a2f79364c8d231e2d1b9b1f7cca43'
  
***REMOVED*** Repeated applications of the hash make brute force (even with a compromised
***REMOVED*** database and site key) harder, and scale with Moore's law.
***REMOVED***
***REMOVED***   bq. "To squeeze the most security out of a limited-entropy password or
***REMOVED***   passphrase, we can use two techniques [salting and stretching]... that are
***REMOVED***   so simple and obvious that they should be used in every password system.
***REMOVED***   There is really no excuse not to use them." http://tinyurl.com/37lb73
***REMOVED***   Practical Security (Ferguson & Scheier) p350
***REMOVED*** 
***REMOVED*** A modest 10 foldings (the default here) adds 3ms.  This makes brute forcing 10
***REMOVED*** times harder, while reducing an app that otherwise serves 100 reqs/s to 78 signin
***REMOVED*** reqs/s, an app that does 10reqs/s to 9.7 reqs/s
***REMOVED*** 
***REMOVED*** More:
***REMOVED*** * http://www.owasp.org/index.php/Hashing_Java
***REMOVED*** * "An Illustrated Guide to Cryptographic Hashes":http://www.unixwiz.net/techtips/iguide-crypto-hashes.html

REST_AUTH_DIGEST_STRETCHES = 10
