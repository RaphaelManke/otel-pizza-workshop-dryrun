const { format } = require('node:util');
const { logs, SeverityNumber } = require('@opentelemetry/api-logs');

const LEVELS = {
  debug: { severityNumber: SeverityNumber.DEBUG, severityText: 'DEBUG' },
  log: { severityNumber: SeverityNumber.INFO, severityText: 'INFO' },
  info: { severityNumber: SeverityNumber.INFO, severityText: 'INFO' },
  warn: { severityNumber: SeverityNumber.WARN, severityText: 'WARN' },
  error: { severityNumber: SeverityNumber.ERROR, severityText: 'ERROR' },
};

let emitting = false;

for (const [method, severity] of Object.entries(LEVELS)) {
  const write = console[method].bind(console);

  console[method] = (...args) => {
    write(...args);

    if (emitting) {
      return;
    }

    emitting = true;
    try {
      logs.getLogger('console').emit({
        severityNumber: severity.severityNumber,
        severityText: severity.severityText,
        body: format(...args),
      });
    } catch {
      // Telemetry must never break the application.
    } finally {
      emitting = false;
    }
  };
}
