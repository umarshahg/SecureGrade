const multer = require('multer');
const Papa = require('papaparse');

const upload = multer({
  limits: { fileSize: 2 * 1024 * 1024 },
  fileFilter: (req, file, cb) => {
    if (file.mimetype !== 'text/csv') {
      return cb(new Error('Only CSV files allowed'));
    }
    cb(null, true);
  },
  storage: multer.memoryStorage()
});

const sanitizeCSV = (buffer) => {
  const content = buffer.toString('utf8');
  const parsed = Papa.parse(content, {
    header: true,
    skipEmptyLines: true
  });

  if (parsed.errors.length > 0) {
    throw new Error('Invalid CSV format');
  }

  return parsed.data.map((row, index) => {
    const rawGrade = String(row.grade || '').replace(/^[=+\-@\t\r]/, '');

    const grade = parseFloat(rawGrade);
    if (isNaN(grade) || grade < 0.0 || grade > 4.0) {
      throw new Error(`Invalid grade at row ${index + 1}: ${rawGrade}`);
    }

    const uuidRegex = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;
    if (!uuidRegex.test(row.student_id)) {
      throw new Error(`Invalid student ID at row ${index + 1}`);
    }

    return { student_id: row.student_id, grade };
  });
};

module.exports = { upload, sanitizeCSV };
