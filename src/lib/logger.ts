export const createLogger = (namespace: string) => {
  return {
    log: (...args: any[]) => console.log(`[${namespace}]`, ...args),
    debug: (...args: any[]) => console.log(`[${namespace}]`, ...args),
    info: (...args: any[]) => console.info(`[${namespace}]`, ...args),
    warn: (...args: any[]) => console.warn(`[${namespace}]`, ...args),
    error: (...args: any[]) => console.error(`[${namespace}]`, ...args),
  }
}
