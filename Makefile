.PHONY: package deploy clean test generate

package:
	@echo "Packaging data pack..."
	rm -f minecraft-helper.datapack.zip
	cd datapack && zip -r ../minecraft-helper.datapack.zip pack.mcmeta data
	@echo "Created minecraft-helper.datapack.zip"

deploy:
	@echo "Deploying to familycraft.jakelab.info..."
	scp -o StrictHostKeyChecking=no minecraft-helper.datapack.zip ubuntu@familycraft.jakelab.info:/tmp/minecraft-helper.datapack.zip
	ssh -o StrictHostKeyChecking=no ubuntu@familycraft.jakelab.info "sudo su -c 'cp /tmp/minecraft-helper.datapack.zip /opt/minecraft/world/datapacks/minecraft-helper.datapack.zip && chown minecraft:minecraft /opt/minecraft/world/datapacks/minecraft-helper.datapack.zip'"
	@echo "Deployed. Run /reload in Minecraft to activate."

generate:
	python3 tools/datapack_gen.py

test:
	python3 -m pytest -q tests sidecar/tests

clean:
	rm -f minecraft-helper.datapack.zip
