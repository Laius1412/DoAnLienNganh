const { db } = require("../firebase/config");

function getDateRange(days) {
  const arr = [];
  const today = new Date();
  for (let i = days - 1; i >= 0; i--) {
    const d = new Date(today);
    d.setDate(today.getDate() - i);
    arr.push(d.toISOString().slice(0, 10));
  }
  return arr;
}

function getMonthRange(months) {
  const arr = [];
  const today = new Date();
  for (let i = months - 1; i >= 0; i--) {
    const d = new Date(today.getFullYear(), today.getMonth() - i, 1);
    arr.push(`${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}`);
  }
  return arr;
}

// Thống kê vé đã xác nhận và doanh thu
async function confirmedBookingStats() {
  const snapshot = await db.collection("bookings").get();
  let confirmed = 0;
  let bookingToday = 0;
  let revenueToday = 0;
  const byDay = {};
  const byMonth = {};
  const byYear = {};
  const revenueByDay = {};
  const revenueByMonth = {};
  const revenueByYear = {};
  const byTrip = {};
  const customerRevenue = {};
  const customerName = {};
  const allDays = new Set();
  const allMonths = new Set();
  const allYears = new Set();

  const todayStr = new Date().toISOString().slice(0, 10);

  for (const doc of snapshot.docs) {
    const data = doc.data();
    if (data.statusBooking !== "confirmed") continue;
    confirmed++;
    let date = "";
    let totalPrice = data.totalPrice || 0;
    if (Array.isArray(data.seats) && data.seats.length > 0) {
      date = data.seats[0].seatPosition?.date || "";
      // Thống kê theo chuyến đi
      const tripName = data.seats[0].vehicle?.trip?.nameTrip || "Không rõ";
      byTrip[tripName] = (byTrip[tripName] || 0) + totalPrice;
    }
    // Thống kê theo khách hàng
    if (data.userId) {
      customerRevenue[data.userId] = (customerRevenue[data.userId] || 0) + totalPrice;
    }
    if (date) {
      const [year, month, day] = date.split("-");
      byDay[date] = (byDay[date] || 0) + 1;
      revenueByDay[date] = (revenueByDay[date] || 0) + totalPrice;
      const monthKey = `${year}-${month}`;
      byMonth[monthKey] = (byMonth[monthKey] || 0) + 1;
      revenueByMonth[monthKey] = (revenueByMonth[monthKey] || 0) + totalPrice;
      byYear[year] = (byYear[year] || 0) + 1;
      revenueByYear[year] = (revenueByYear[year] || 0) + totalPrice;
      allDays.add(date);
      allMonths.add(monthKey);
      allYears.add(year);
      if (date === todayStr) {
        bookingToday++;
        revenueToday += totalPrice;
      }
    }
  }

  // Lấy tên khách hàng cho top 10
  const userIds = Object.keys(customerRevenue);
  if (userIds.length > 0) {
    const userSnaps = await db.collection('users').where('__name__', 'in', userIds.slice(0, 10)).get();
    userSnaps.forEach(doc => {
      customerName[doc.id] = doc.data().name || doc.data().email || doc.id;
    });
  }
  // Sắp xếp top 10 khách hàng
  const topCustomers = Object.entries(customerRevenue)
    .map(([userId, revenue]) => ({
      name: customerName[userId] || userId,
      revenue
    }))
    .sort((a, b) => b.revenue - a.revenue)
    .slice(0, 10);

  // 7 ngày gần nhất
  const last7Days = getDateRange(7);
  const bookingByDay = {};
  const bookingRevenueByDay = {};
  last7Days.forEach(d => {
    bookingByDay[d] = byDay[d] || 0;
    bookingRevenueByDay[d] = revenueByDay[d] || 0;
  });

  // 12 tháng gần nhất
  const last12Months = getMonthRange(12);
  const bookingByMonth = {};
  const bookingRevenueByMonth = {};
  last12Months.forEach(m => {
    bookingByMonth[m] = byMonth[m] || 0;
    bookingRevenueByMonth[m] = revenueByMonth[m] || 0;
  });

  // Tất cả các năm có dữ liệu
  const years = Array.from(allYears).sort();
  const bookingByYear = {};
  const bookingRevenueByYear = {};
  years.forEach(y => {
    bookingByYear[y] = byYear[y] || 0;
    bookingRevenueByYear[y] = revenueByYear[y] || 0;
  });

  return {
    confirmed,
    bookingToday,
    revenueToday,
    bookingByDay,
    bookingByMonth,
    bookingByYear,
    bookingRevenueByDay,
    bookingRevenueByMonth,
    bookingRevenueByYear,
    bookingByTrip: byTrip,
    topCustomers,
    allDays: Array.from(allDays).sort(),
    allMonths: Array.from(allMonths).sort(),
    allYears: years
  };
}

exports.getDashboardStats = async (req, res) => {
  try {
    const { from, to, monthFrom, monthTo, yearFrom, yearTo } = req.query;
    const [vehicleCount, userCount, bookingStat] = await Promise.all([
      db.collection("vehicle").get().then(s => s.size),
      db.collection("users").get().then(s => s.size),
      confirmedBookingStats()
    ]);

    // Lọc theo ngày nếu có from/to
    let bookingByDay = bookingStat.bookingByDay;
    let bookingRevenueByDay = bookingStat.bookingRevenueByDay;
    if (from && to) {
      const fromDate = new Date(from);
      const toDate = new Date(to);
      bookingByDay = {};
      bookingRevenueByDay = {};
      for (let d = new Date(fromDate); d <= toDate; d.setDate(d.getDate() + 1)) {
        const key = d.toISOString().slice(0, 10);
        bookingByDay[key] = bookingStat.bookingByDay[key] || 0;
        bookingRevenueByDay[key] = bookingStat.bookingRevenueByDay[key] || 0;
      }
    }
    // Lọc theo tháng nếu có monthFrom/monthTo
    let bookingByMonth = bookingStat.bookingByMonth;
    let bookingRevenueByMonth = bookingStat.bookingRevenueByMonth;
    if (monthFrom && monthTo) {
      const fromParts = monthFrom.split('-');
      const toParts = monthTo.split('-');
      const fromDate = new Date(Number(fromParts[0]), Number(fromParts[1]) - 1, 1);
      const toDate = new Date(Number(toParts[0]), Number(toParts[1]) - 1, 1);
      bookingByMonth = {};
      bookingRevenueByMonth = {};
      for (let d = new Date(fromDate); d <= toDate; d.setMonth(d.getMonth() + 1)) {
        const key = `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}`;
        bookingByMonth[key] = bookingStat.bookingByMonth[key] || 0;
        bookingRevenueByMonth[key] = bookingStat.bookingRevenueByMonth[key] || 0;
      }
    }
    // Lọc theo năm nếu có yearFrom/yearTo
    let bookingByYear = bookingStat.bookingByYear;
    let bookingRevenueByYear = bookingStat.bookingRevenueByYear;
    if (yearFrom && yearTo) {
      const fromYear = Number(yearFrom);
      const toYear = Number(yearTo);
      bookingByYear = {};
      bookingRevenueByYear = {};
      for (let y = fromYear; y <= toYear; y++) {
        bookingByYear[y] = bookingStat.bookingByYear[y] || 0;
        bookingRevenueByYear[y] = bookingStat.bookingRevenueByYear[y] || 0;
      }
    }

    res.render("dashboard", {
      vehicleCount,
      userCount,
      bookingConfirmed: bookingStat.confirmed,
      bookingToday: bookingStat.bookingToday,
      revenueToday: bookingStat.revenueToday,
      bookingByDay,
      bookingByMonth,
      bookingByYear,
      bookingRevenueByDay,
      bookingRevenueByMonth,
      bookingRevenueByYear,
      bookingByTrip: bookingStat.bookingByTrip,
      topCustomers: bookingStat.topCustomers,
      allDays: bookingStat.allDays,
      allMonths: bookingStat.allMonths,
      allYears: bookingStat.allYears,
      layout: "layout"
    });
  } catch (err) {
    console.error("Lỗi thống kê dashboard:", err);
    res.status(500).send("Lỗi thống kê dashboard");
  }
}; 