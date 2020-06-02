const fs = require("fs");
const yaml = require("js-yaml");
const url = require("url");
const YAML = require("json-to-pretty-yaml");

const logEnv = function(envName, envConfig) {
	fs.promises
		.mkdir(`./envs/${envName}`, { recursive: true })
		.catch(console.error);

	console.log(`Parsing env ${envName}`);
	const { apps } = envConfig;
	Object.entries(apps).map(([key, val]) => {
		const { apps } = envConfig;
		logApp(key, {
			client: envConfig.client,
			project: envConfig.project,
			appuio_project: envConfig.appuio_project,
			envName,
			...val,
		});
	});
};

const logApp = function(appName, appConfig) {
	console.log(`Parsing app ${appConfig.envName}-${appName}`);

	const projectRepoName = appConfig.project;
	const alias = appConfig.alias ? url.parse(appConfig.alias) : null;
	const path = !alias || alias.path === "/" ? "" : alias.path;

	const envfile = {
		APPUIO_PROJECT: appConfig.appuio_project,
		CLIENT: appConfig.client,
		PROJECT: appConfig.project,
		PART: appName,
		IMAGE_NAME: `${appConfig.client}-${projectRepoName}:${appName}-${appConfig.envName}`,
		HOSTNAME: alias ? `${alias.auth ? alias.auth : ""}${alias.host}` : "",
		DEPLOY_PATH: path,
		ENVIRONMENT: appConfig.envName,
		PORT: appConfig.port,
		NB_REPLICAS: appConfig.replicas ? appConfig.replicas : 1,
	};
	const envfileString = `
APPUIO_PROJECT: ${envfile.APPUIO_PROJECT}
CLIENT: ${envfile.CLIENT}
PROJECT: ${envfile.PROJECT}
PART: ${envfile.PART}
IMAGE_NAME: ${envfile.IMAGE_NAME}
HOSTNAME: ${envfile.HOSTNAME}
DEPLOY_PATH: ${envfile.DEPLOY_PATH}
ENVIRONMENT: ${envfile.ENVIRONMENT}
PORT: ${envfile.PORT}
NB_REPLICAS: ${envfile.NB_REPLICAS}
	  `;

	fs.promises
		.mkdir(`./envs/${appConfig.envName}/${appName}/`, { recursive: true })
		.catch(console.error);
	fs.writeFile(
		`./envs/${appConfig.envName}/${appName}/env`,
		envfileString,
		(err) => {
			// throws an error, you could also catch it here
			if (err) throw err;

			// success case, the file was saved
			console.log(`Generated enfile for ${appConfig.envName}-${appName}`);
		}
	);
};

const json = require("../../hosting.config.json");
const configYaml = YAML.stringify(json);

try {
	var config = yaml.safeLoad(configYaml);
	const { environments } = config;
	fs.promises.mkdir("./envs", { recursive: true }).catch(console.error);

	Object.entries(environments).map(([key, val]) => {
		logEnv(key, {
			...val,
			client: config.client,
			project: config.project,
		});
	});
} catch (e) {
	console.log(e);
}
