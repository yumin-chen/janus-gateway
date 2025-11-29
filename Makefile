init:
	mkdir -p ci config/wireguard content docs/architecture/design docs/guidelines/decisions docs/technical/specs modules scripts src

enable-gateway:
	bash scripts/gateway-enable.sh

disable-gateway:
	bash scripts/gateway-disable.sh

start-tunnel:
	bash scripts/start-tunnel.sh
