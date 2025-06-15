export const createLogger = (namespace: string) => {
  return {
    log: (...args: any[]) => console.log(`[TEXT] [${namespace}]`, ...args),
    debug: (...args: any[]) => console.log(`[DBUG] [${namespace}]`, ...args),
    info: (...args: any[]) => console.info(`[INFO] [${namespace}]`, ...args),
    warn: (...args: any[]) => console.warn(`[WARN] [${namespace}]`, ...args),
    error: (...args: any[]) => console.error(`[!ERR] [${namespace}]`, ...args),
  }
}
