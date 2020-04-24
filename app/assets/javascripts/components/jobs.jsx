class searchButton extends React.Component {
	constructor(props) {
	    super(props);
	    this.state = {value: this.props.query};
	    this.handleChange = this.handleChange.bind(this);
  	}

  	handleChange(event) {
  	    this.setState({value: event.target.value});
  	    //<% @query = event.target.value %>
  	    //console.log(event.target.value)
  	}
    render() {
        return <div><div className="col-md-10 job-search-input">
                        <input className="form-control" id="query" name="query" type="text" placeholder= "Start typing what you want to search..." autoFocus defaultValue={this.props.query} onChange={this.handleChange} value={this.state.value}/>
                    </div>
                    <div className="col-md-2">
                        <input className="btn btn-info pull-right" id="do-job-search" type="submit" value="Search"/>
                    </div>
                </div>
    }
}

// class searchInfo extends React.Component {
//     render() {
//         return <div className="col-lg-4 col-sm-12" id="advanced_search">
//                     <div className="card card-x">
//                         <label htmlFor="department" class="filter-dropdown-label">Department</label>
//                         <select id="department" ></select>
//                         <label htmlFor="compensation" class="filter-dropdown-label">Compensation</label>
//                         <%= select_tag :compensation, options_for_select({
//                         "Don't care" => Job::Compensation::None,
//                         "Pay"        => Job::Compensation::Pay,
//                         "Credit"     => Job::Compensation::Credit,
//                         "Pay or credit" => Job::Compensation::Both
//                         }, @compensation) %>
//                         <input id="as" name="as" type="hidden"/>
//                         <label htmlFor="per_page" class="filter-dropdown-label">Listings per page</label>
//                         <%= select_tag :per_page, options_for_select([8,16,32,64,128], params[:per_page].to_i), :multiple=>false %>
//                         <select id="per_page"> 
//                             <option value="8">8</option>
//                         </select>
//                         <input id="do-job-filter" className="btn btn-info" type="submit" value="Filter"/>
//                     </div>
//                 </div>
//     }
// }