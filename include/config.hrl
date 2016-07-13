-record(config, {
          cookie = base64:encode(crypto:strong_rand_bytes(24))
}).
