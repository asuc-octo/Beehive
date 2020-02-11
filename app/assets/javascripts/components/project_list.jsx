class ProjectList extends React.Component {
	/**
	 * Params:
	 * 	path - Path of job link
	 * 	title - Name of job
	 *	tags?????
	 *	description - Description of job
	 *	update_time - Last updated time of job
	 *	id - ID of job
	 *	user_included? - is the current user included within the job's users
	 */


	render(){
		let list = null;
  		if (this.props.list_name.includes("Watched")){
  			//let content = {this.props.watched_empty ? "You are not watching any projects." : {this.props.watched_jobs}}
  			list =  <div className="card">
			          <h2>{this.props.list_name}</h2>
			          {this.props.watched_empty ? this.props.default_message : <div dangerouslySetInnerHTML={{__html: this.props.watched_jobs}}></div>}
			        </div>
  		} else {
			list =  <div className="card">
			          <h2>{this.props.list_name}</h2>
			          {(this.props.jobs_empty && this.props.owned_jobs_empty) ? <p dangerouslySetInnerHTML={{__html: this.props.default_message}}></p> : null}
			          {this.props.jobs_present ? <div dangerouslySetInnerHTML={{__html: this.props.jobs}}></div> : null} 	
			          {this.props.owned_jobs_present ? <div> this.owned_jobs_heading <div dangerouslySetInnerHTML={{__html: this.props.owned_jobs}}></div></div> : null}
        			</div>
		}
		return list
	}
}

/*class Tag extends React.Component {
	/**
	* path - path of the tag link (search_path(@tags, tag))
	*/
	/*render(){
		return <Link to={this.props.path} class="tags">{this.props.label}</Link>
	}
}*/