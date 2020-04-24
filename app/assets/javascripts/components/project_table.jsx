class ProjectTable extends React.Component {
  /**
   * Params:
   *  table_name - Title of card
   *  empty - Jobs empty?
   *  empty_text - message to display if jobs is empty
   *  table_data - HTML for rendering the table
   */
  componentDidMount() {
    // Javascript to set sorting only when the table is rendered
    $('.job_table').each(function(index, elem) {
      table = $(elem).DataTable({
        destroy: true,
        searching: false,
        paging: false,
        columnDefs: [{targets: 0, orderData: [0, 3]}, {targets: 1, orderData: [1, 3]}, {targets: 2, orderData: [2, 3]}, {targets: 3, orderData: [3, 0], type: "status"}]
      });
    });
  }
  render(){
      let table;
      if (this.props.empty){
          table = <div>{this.props.empty_text}</div>
      } else {
        table = <table className="job_table table table-striped table-condensed">
                  <thead>
                    <tr>
                      <th className="col-md-2">Application Date</th>
                      <th className="col-md-4">Project</th>
                      <th className="col-md-2">Contact</th>
                      <th className="col-md-2">Status</th>
                    </tr>
                  </thead>
                  <tbody dangerouslySetInnerHTML={{__html: this.props.table_data}}></tbody>
                </table>
      }
      return  <div className="card"> 
                <h2>{this.props.table_name}</h2>
                {table}
              </div>
  }
}