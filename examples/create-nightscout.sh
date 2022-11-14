#!/usr/bin/env bash
# "image":"nightscout/cgm-remote-monitor:latest",


generate_post_data()
{
  cat<<EOF
  {
  "name":"nightscout-$1",
  "network":"traefiknet",
  "image":"nickxbs/cgm-remote-monitor:ni",
  "labels": {
		"traefik.enable": "true",
		"traefik.http.routers.nightscout-$1.entrypoints": "web",
		"traefik.http.routers.nightscout-$1.rule": "PathPrefix(\"/session/nightscout-$1\")",
		"traefik.http.services.nightscout-$1.loadbalancer.server.port": "80",
		"traefik.http.middlewares.nightscout-ss$1.stripprefix.prefixes": "/session",			
		"traefik.http.middlewares.nightscout-st$1.stripprefix.prefixes": "/session/nightscout-$1",			
		"traefik.http.middlewares.nightscout-st$1.stripprefix.forceSlash": "false", 
		"traefik.http.routers.nightscout-$1.middlewares": "nightscout-st$1,nightscout-ss$1",
  },
  "envs": {
			"INSECURE_USE_HTTP": "false",
			"NODE_ENV": "production",
			"PORT": "80",
			"TZ": "Etc/UTC",
			"INSECURE_USE_HTTP": "true",
			"MONGO_CONNECTION": "mongodb+srv://localhost/ns$1?retryWrites=true&w=majority",
			"API_SECRET": "change_me_please",
			"ENABLE": "careportal rawbg iob",
			"AUTH_DEFAULT_ROLES": "readable"	}
  }
EOF
}



for i in {0..1}; do 
response=$(curl -s --header "Content-Type: application/json" \
     -X POST \
     --data  "$(generate_post_data $i)" localhost/v1/)

  if command -v jq > /dev/null 2>&1; then
    echo $response | jq
  else
    echo "Install jq for a better output"
    echo $response
  fi
done
