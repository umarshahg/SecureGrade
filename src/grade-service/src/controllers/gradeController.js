const db = require('../config/db');
const { sanitizeCSV } = require('../middleware/fileValidator');
const auditService = require('../services/auditService');

const uploadGrades = async (req, res) => {
  try {
    const teacherId = req.user.sub;
    const { courseId } = req.body;

    const assigned = await db.query(
      `SELECT 1 FROM course_assignments
       WHERE teacher_id = $1 AND course_id = $2`,
      [teacherId, courseId]
    );

    if (!assigned.rows[0]) {
      return res.status(403).json({ message: 'Forbidden' });
    }

    const grades = sanitizeCSV(req.file.buffer);

    for (const grade of grades) {
      await db.query(
        `INSERT INTO grade_submissions
         (student_id, course_id, teacher_id, grade, status)
         VALUES ($1, $2, $3, $4, 'pending')`,
        [grade.student_id, courseId, teacherId, grade.grade]
      );
    }

    await auditService.log('GRADES_UPLOADED', {
      teacherId,
      courseId,
      count: grades.length,
      ip: req.ip,
      timestamp: new Date().toISOString()
    });

    return res.status(200).json({
      message: `${grades.length} grades submitted for approval`
    });

  } catch (err) {
    return res.status(400).json({ message: err.message });
  }
};

module.exports = { uploadGrades };
