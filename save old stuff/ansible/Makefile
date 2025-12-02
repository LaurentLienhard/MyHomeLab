.PHONY: prepare
prepare-desc = "Prepare local workspace"
prepare:
	@echo "==> $(env-desc)"

	@[ -d "${PWD}/.direnv" ] || (echo "Venv not found: ${PWD}/.direnv" && exit 1)

	@python -m pip install --trusted-host pypi.python.org --trusted-host files.pythonhosted.org --trusted-host pypi.org ansible-core --no-cache-dir && \
		echo "[  OK  ] ANSIBLE CORE" || \
		echo "[FAILED] ANSIBLE CORE"

	@python -m pip install --trusted-host pypi.python.org --trusted-host files.pythonhosted.org --trusted-host pypi.org wheel setuptools --no-cache-dir && \
		echo "[  OK  ] PIP + WHEEL + SETUPTOOLS" || \
		echo "[FAILED] PIP + WHEEL + SETUPTOOLS"

	@python -m pip install --trusted-host pypi.python.org --trusted-host files.pythonhosted.org --trusted-host pypi.org -U --no-cache-dir -r "${PWD}/requirements.txt" && \
		echo "[  OK  ] PIP REQUIREMENTS" || \
		echo "[FAILED] PIP REQUIREMENTS"

	@ansible-galaxy install -fr "${PWD}/requirements.yml" --ignore-errors --ignore-certs && \
		echo "[  OK  ] ANSIBLE-GALAXY REQUIREMENTS" || \
		echo "[FAILED] ANSIBLE-GALAXY REQUIREMENTS"
