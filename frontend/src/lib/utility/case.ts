export const snakeToCamel = (key: string): string =>
  key.replace(/_([a-z0-9])/g, (_, char) => char.toUpperCase());

export const camelToSnake = (key: string): string =>
  key.replace(/[A-Z]/g, (char) => `_${char.toLowerCase()}`);

const isPlainObject = (value: unknown): value is Record<string, unknown> =>
  typeof value === 'object' && value !== null && !Array.isArray(value) && !(value instanceof Date);

const deepConvert = (value: unknown, convertKey: (key: string) => string): unknown => {
  if (Array.isArray(value)) return value.map((item) => deepConvert(item, convertKey));

  if (isPlainObject(value)) {
    return Object.fromEntries(
      Object.entries(value).map(([key, val]) => [convertKey(key), deepConvert(val, convertKey)])
    );
  }

  return value;
};

export const toCamelCase = <T>(value: unknown): T => deepConvert(value, snakeToCamel) as T;

export const toSnakeCase = <T>(value: unknown): T => deepConvert(value, camelToSnake) as T;
