document.addEventListener("DOMContentLoaded", e => {
	var xhr = new XMLHttpRequest();
	xhr.open('GET', './data.json', true);
	xhr.send();
	xhr.onload = e => {
		let data = JSON.parse(xhr.responseText);
		// console.log(data);
		stat(data);
	}
});
let grow = (p, n) =>
	(p > n ? '-' : '+') +
	(p > n
		? (p - n) / (p / 100)
		: (n - p) / (n / 100)
	).toFixed(1) +
	'%';	
let bdate = e => {
	e = e / 1000;
	if(e < 60) {return (e | 0) + 'с.'}
	e = e / 60;
	if(e < 60) {return (e | 0) + 'м.'}
	e = e / 60;
	if(e < 24) {return (e | 0) + 'ч.'}
	e = e / 24;
	return (e | 0) + 'д.';
};
let stat = e => {
	for(el of e.data) {
		// console.log(el);
		document.getElementById('area').innerHTML += `
		<div class="store">
			<div class="storename b">${el.name.toUpperCase()}</div>
			<div class="positions">
				${el.positions.map(pos => `
				<div class="position">
					<div class="name b">
						<a href="${pos.url}" target="_blank" title="record ID: ${pos.id}">
							${pos.name.replace(/\_/g, ' ')}
							<div class="hint">
								<!--
								<canvas id="${addcanvas(pos)}"></canvas>
								-->
							</div>
						</a>
					</div>
					<div class="rows">
					${pos.rows.map((e, i, a) => `
						<span>&nbsp;${i > 0 ? (
							bdate(
								new Date(a[i]    .date.replace(/\(|\)/g, '')).getTime() -
								new Date(a[i - 1].date.replace(/\(|\)/g, '')).getTime()
							)
						) : ''}&nbsp;</span>
						<span class="price ${i == 0 ? 'green' : a[i - 1].price > e.price ? e.price ? 'green' : 'red' : 'red'} b" title="${e.date}">
							${e.price
								? `${e.price}
									<sup>
										${
											i > 0
												? grow(a[i - 1].price, a[i].price)
												: ''
										}
									</sup>`
								: 'Нет в наличии'
							}
						</span>
					`).join('\n')}
					<span>&nbsp;${
							bdate(
								new Date()                                                        .getTime() -
								new Date(pos.rows[pos.rows.length - 1].date.replace(/\(|\)/g, '')).getTime()
							)
					}&nbsp;</span>
					</div>
				</div>
				`).join('\n')}
			</div>
		</div>`
	}
	// gencanvases();
}
let canvases = [];
let addcanvas = data => {
	canvases.push(data)
	return 'canvas_' + canvases.length;
}
let gencanvases = e => {
	let width    = 600;// (window.innerWidth / 100 * 95) | 0,
	    height   = 160;
	for(i in canvases) {
		let minPrice = -1,
		    maxPrice = -1,
		    minDate  = -1,
		    maxDate  = -1;

		for(let row of canvases[i].rows) {
			
			let date = new Date(row.date.replace(/\(|\)/g, '')).getTime();
			row._date = date;

			minDate = minDate > date || minDate < 0 ? date : minDate;
			maxDate = maxDate < date || maxDate < 0 ? date : maxDate;

			if(row.price != '') {
				minPrice = minPrice > row.price || minPrice < 0 ? row.price : minPrice;
				maxPrice = maxPrice < row.price || maxPrice < 0 ? row.price : maxPrice;
			}

			// canvases[i].minDate  = minDate;
			// canvases[i].maxDate  = maxDate;
			// canvases[i].minPrice = minPrice;
			// canvases[i].maxPrice = maxPrice;

			// if(minPrice == maxPrice) {
			// 	minPrice = 0;
			// }
		}		

		let _width = maxDate - minDate;

		let el = document.getElementById('canvas_' + ((i | 0) + 1));
		el.width = width;
		el.height = height;
		let ctx = el.getContext('2d');
		ctx.strokeStyle = '#0000ff';
		console.log('-----------', _width, maxPrice, 'length:', canvases[i].rows.length);
		for(let rowIndex in canvases[i].rows) {
			let row = canvases[i].rows[rowIndex];
			let x = (row._date - minDate) * (width / _width),
			    y = row.price * (height / maxPrice);
			console.log('>>>', row.price, row._date - minDate);
			console.log(x, y);
			if(rowIndex == 0) {
				ctx.moveTo(x, y);
			} else {
				ctx.lineTo(x, y);
			}
		}

		ctx.stroke();
	}
};
