declare module 'sol2ligo';

interface compilation_options {
  solc_version?: string,
  suggest_solc_version?: string,
  auto_version?: boolean,
  allow_download?: boolean,
  router?: boolean,
  contract?: string,
  replace_enums_by_nats?: boolean
  debug?: boolean
}

interface compilation_result {
  errors: [object],
  warnings: [object],
  ligo_code: string,
  default_state: string,
  prevent_deploy: boolean
}

export function compile(sol_code: string, opt: compilation_options): compilation_result;

export function import_resolver(path: string, import_cache: object): string;
