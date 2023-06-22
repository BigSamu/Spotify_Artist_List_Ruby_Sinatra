$(document).ready(function () {
  $.ajax({
    url: 'http://localhost:4567/get_artists_list',
    type: 'GET',
    success: function (data) {
      let table = `
      <table class="table w-75 table-striped">
        <thead>
          <tr>
            <th scope="col">#</th>
            <th scope="col">Name</th>
            <th scope="col">Popularity</th>
            <th scope="col">Top Song</th>
            <th scope="col">Preview URL</th>
          </tr>
        </thead>
        <tbody>
      `;
      let idx = 1;
      for (const artist of data) {
        table += `<tr>`;
        table += `<th scope="row">${idx}</th>`;
        table += `<td>${artist.name}</td>`;
        table += `<td>${artist.popularity}</td>`;
        table += `<td>${artist.top_song}</td>`;
        table += `<td>`;
        if (artist.preview_url) {
          table += `<a href="${artist.preview_url}" target="_blank">Preview</a>`;
        } else {
          table += `None`;
        }
        table += `</td>`;
        table += `</tr>`;
        idx++;
      }

      table += `
        </tbody>
      </table>
      `;

      $('#table-container').append(table);
      $('#spinner-loader').remove();
    },
    error: function (error) {
      console.log(error);
    },
  });
});
